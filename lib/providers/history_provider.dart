import 'package:flutter/material.dart';
import 'package:machine_guard/data/models/prediction_result.dart';
import 'package:machine_guard/data/services/database_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<PredictionResult> _all = [];
  String _filter = 'all'; // all | atRisk | healthy

  List<PredictionResult> get filtered {
    if (_filter == 'atRisk') {
      return _all.where((r) => r.riskLevel != RiskLevel.healthy).toList();
    } else if (_filter == 'healthy') {
      return _all.where((r) => r.riskLevel == RiskLevel.healthy).toList();
    }
    return _all;
  }

  String get filter => _filter;
  int get total => _all.length;
  int get atRiskCount => _all.where((r) => r.riskLevel != RiskLevel.healthy).length;
  int get healthyCount => _all.where((r) => r.riskLevel == RiskLevel.healthy).length;

  Future<void> load() async {
    _all = await DatabaseService.getAllPredictions();
    notifyListeners();
  }

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> deleteById(int id) async {
    await DatabaseService.deletePrediction(id);
    await load();
  }

  Future<void> clearAll() async {
    await DatabaseService.clearAll();
    _all = [];
    notifyListeners();
  }
}
