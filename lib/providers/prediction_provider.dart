import 'package:flutter/material.dart';
import 'package:machine_guard/data/models/sensor_input.dart';
import 'package:machine_guard/data/models/prediction_result.dart';
import 'package:machine_guard/data/services/api_service.dart';
import 'package:machine_guard/data/services/database_service.dart';

enum PredictionState { idle, loading, success, error }

class PredictionProvider extends ChangeNotifier {
  final ApiService _apiService;

  PredictionProvider(this._apiService);

  PredictionState _state = PredictionState.idle;
  PredictionResult? _latestResult;
  String? _errorMessage;

  PredictionState get state => _state;
  PredictionResult? get latestResult => _latestResult;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == PredictionState.loading;

  Future<void> runPrediction(SensorInput input) async {
    _state = PredictionState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.predict(input);
      _latestResult = result;
      _state = PredictionState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = PredictionState.error;
    }
    notifyListeners();
  }

  Future<void> saveResult() async {
    if (_latestResult != null) {
      await DatabaseService.insertPrediction(_latestResult!);
    }
  }

  void reset() {
    _state = PredictionState.idle;
    _latestResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
