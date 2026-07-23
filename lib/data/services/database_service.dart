import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:machine_guard/core/constants/app_constants.dart';
import 'package:machine_guard/data/models/prediction_result.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static const _createTableSql = '''
    CREATE TABLE ${AppConstants.tableHistory} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      machine_id TEXT NOT NULL,
      predicted_class TEXT NOT NULL,
      confidence REAL NOT NULL,
      class_probabilities TEXT NOT NULL,
      is_healthy INTEGER NOT NULL,
      low_confidence INTEGER NOT NULL,
      recommendation TEXT NOT NULL,
      sensor_alerts TEXT NOT NULL,
      alert_count INTEGER NOT NULL,
      critical_count INTEGER NOT NULL,
      warning_count INTEGER NOT NULL,
      model_version TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
  ''';

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute(_createTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Old installs had the binary-risk schema (risk_level, risk_probability,
        // etc.), which no longer applies now the model outputs a multi-class
        // fault type. Simplest safe migration for a dev-stage app: drop and
        // recreate — clears existing local history on upgrade, which is fine
        // while there's no real user data to preserve.
        await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableHistory}');
        await db.execute(_createTableSql);
      },
    );
  }

  static Future<int> insertPrediction(PredictionResult result) async {
    final db = await database;
    return db.insert(AppConstants.tableHistory, result.toMap());
  }

  static Future<List<PredictionResult>> getAllPredictions() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableHistory,
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => PredictionResult.fromMap(m)).toList();
  }

  static Future<void> deletePrediction(int id) async {
    final db = await database;
    await db.delete(AppConstants.tableHistory, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete(AppConstants.tableHistory);
  }

  static Future<Map<String, int>> getSummary() async {
    final db = await database;
    final all = await db.query(AppConstants.tableHistory);
    int total = all.length;
    int faulty = all.where((m) => m['is_healthy'] == 0).length;
    return {'total': total, 'faulty': faulty, 'healthy': total - faulty};
  }
}
