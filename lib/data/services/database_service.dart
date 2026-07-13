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

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppConstants.tableHistory} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            machine_id TEXT NOT NULL,
            prediction INTEGER NOT NULL,
            risk_probability REAL NOT NULL,
            risk_percentage REAL NOT NULL,
            risk_level TEXT NOT NULL,
            recommendation TEXT NOT NULL,
            model_version TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
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
    int atRisk = all.where((m) => m['risk_level'] != 'healthy').length;
    return {'total': total, 'atRisk': atRisk, 'healthy': total - atRisk};
  }
}
