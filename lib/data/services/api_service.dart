import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:machine_guard/core/constants/app_constants.dart';
import 'package:machine_guard/data/models/prediction_result.dart';
import 'package:machine_guard/data/models/sensor_input.dart';


class ApiService {
  String _baseUrl;

  ApiService({String? baseUrl})
      : _baseUrl = baseUrl ?? AppConstants.defaultApiUrl;

  void updateBaseUrl(String url) => _baseUrl = url;

  String get _v1 => '$_baseUrl${AppConstants.apiV1}';

  Future<bool> checkHealth() async {
    try {
      // Longer timeout: Render free tier can take 30-60s to wake from sleep
      final response = await http
          .get(Uri.parse('$_v1/health'))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok' && data['model_loaded'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<PredictionResult> predict(SensorInput input) async {
    try {
      // Bumped from 30s -> 90s. Render's free tier spins down after ~15 min
      // idle and can take 30-60s+ to wake back up on the first request.
      final response = await http
          .post(
            Uri.parse('$_v1/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(input.toJson()),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 422) {
        final detail = jsonDecode(response.body)['detail'];
        throw Exception('Validation error: $detail');
      } else if (response.statusCode == 503) {
        throw Exception('Model not loaded on server. Please try again later.');
      } else {
        throw Exception('Prediction failed (${response.statusCode})');
      }
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Server took too long to respond. It may be waking up from '
            'sleep (Render free tier: please try again in a moment.');
      }
      rethrow;
    }
  }

  Future<List<String>> getMachineTypes() async {
    try {
      final response = await http
          .get(Uri.parse('$_v1/machines/types'))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['machine_types']);
      }
    } catch (_) {}
    return AppConstants.machineTypes;
  }

  Future<List<String>> getOperatingModes() async {
    try {
      final response = await http
          .get(Uri.parse('$_v1/machines/operating-modes'))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['operating_modes']);
      }
    } catch (_) {}
    return AppConstants.operatingModes;
  }
}
