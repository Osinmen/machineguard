import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:machine_guard/core/theme/app_theme.dart';

class SensorAlert {
  final String sensor;
  final String featureKey;
  final double value;
  final String unit;
  final String status;
  final String message;
  final List<double> warnRange;
  final List<double> critRange;

  SensorAlert({
    required this.sensor,
    required this.featureKey,
    required this.value,
    required this.unit,
    required this.status,
    required this.message,
    required this.warnRange,
    required this.critRange,
  });

  factory SensorAlert.fromJson(Map<String, dynamic> json) {
    return SensorAlert(
      sensor:     json['sensor'],
      featureKey: json['feature_key'],
      value:      (json['value'] as num).toDouble(),
      unit:       json['unit'],
      status:     json['status'],
      message:    json['message'],
      warnRange:  List<double>.from(json['warn_range'].map((e) => (e as num).toDouble())),
      critRange:  List<double>.from(json['crit_range'].map((e) => (e as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() => {
    'sensor':      sensor,
    'feature_key': featureKey,
    'value':       value,
    'unit':        unit,
    'status':      status,
    'message':     message,
    'warn_range':  warnRange,
    'crit_range':  critRange,
  };

  bool get isCritical => status == 'CRITICAL';

  Color get alertColor => isCritical ? AppColors.red : AppColors.orange;

  IconData get alertIcon => isCritical
      ? Icons.error_outline
      : Icons.warning_amber_outlined;
}

class PredictionResult {
  final String machineId;
  final String predictedClass;       // healthy | bearing | electrical | hydraulic | motor_overheat
  final double confidence;           // probability of predictedClass, 0.0–1.0
  final Map<String, double> classProbabilities;
  final bool isHealthy;
  final bool lowConfidence;
  final String recommendation;
  final List<SensorAlert> sensorAlerts;
  final int alertCount;
  final int criticalCount;
  final int warningCount;
  final String modelVersion;
  final DateTime timestamp;

  PredictionResult({
    required this.machineId,
    required this.predictedClass,
    required this.confidence,
    required this.classProbabilities,
    required this.isHealthy,
    required this.lowConfidence,
    required this.recommendation,
    required this.sensorAlerts,
    required this.alertCount,
    required this.criticalCount,
    required this.warningCount,
    required this.modelVersion,
    required this.timestamp,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      machineId:      json['machine_id'],
      predictedClass: json['predicted_class'],
      confidence:     (json['confidence'] as num).toDouble(),
      classProbabilities: (json['class_probabilities'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      isHealthy:      json['is_healthy'] ?? (json['predicted_class'] == 'healthy'),
      lowConfidence:  json['low_confidence'] ?? false,
      recommendation: json['recommendation'],
      sensorAlerts:   (json['sensor_alerts'] as List)
                          .map((a) => SensorAlert.fromJson(a))
                          .toList(),
      alertCount:     json['alert_count'] ?? 0,
      criticalCount:  json['critical_count'] ?? 0,
      warningCount:   json['warning_count'] ?? 0,
      modelVersion:   json['model_version'] ?? '2.0.0',
      timestamp:      DateTime.now(),
    );
  }

  // Reuses the same cyan/orange/red visual language the old risk-tier UI
  // used, but driven by prediction confidence rather than a risk score:
  // healthy -> cyan, uncertain fault -> orange, confident fault -> red.
  Color get statusColor {
    if (isHealthy) return AppColors.cyan;
    return lowConfidence ? AppColors.orange : AppColors.red;
  }

  String get statusLabel => isHealthy
      ? 'HEALTHY'
      : '${predictedClass.replaceAll('_', ' ').toUpperCase()} FAULT';

  IconData get statusIcon {
    if (isHealthy) return Icons.check_circle_outline;
    return lowConfidence ? Icons.help_outline : Icons.cancel_outlined;
  }

  double get confidencePercentage => confidence * 100;

  // Class probabilities sorted highest first, for the breakdown list.
  List<MapEntry<String, double>> get sortedProbabilities {
    final entries = classProbabilities.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  Map<String, dynamic> toMap() => {
    'machine_id':          machineId,
    'predicted_class':     predictedClass,
    'confidence':          confidence,
    'class_probabilities': jsonEncode(classProbabilities),
    'is_healthy':          isHealthy ? 1 : 0,
    'low_confidence':      lowConfidence ? 1 : 0,
    'recommendation':      recommendation,
    'sensor_alerts':       jsonEncode(sensorAlerts.map((a) => a.toJson()).toList()),
    'alert_count':         alertCount,
    'critical_count':      criticalCount,
    'warning_count':       warningCount,
    'model_version':       modelVersion,
    'timestamp':           timestamp.toIso8601String(),
  };

  factory PredictionResult.fromMap(Map<String, dynamic> map) {
    final probsRaw = jsonDecode(map['class_probabilities']) as Map<String, dynamic>;
    final alertsRaw = jsonDecode(map['sensor_alerts']) as List;
    return PredictionResult(
      machineId:      map['machine_id'],
      predictedClass: map['predicted_class'],
      confidence:     (map['confidence'] as num).toDouble(),
      classProbabilities: probsRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      isHealthy:      map['is_healthy'] == 1,
      lowConfidence:  map['low_confidence'] == 1,
      recommendation: map['recommendation'],
      sensorAlerts:   alertsRaw.map((a) => SensorAlert.fromJson(a)).toList(),
      alertCount:     map['alert_count'] ?? 0,
      criticalCount:  map['critical_count'] ?? 0,
      warningCount:   map['warning_count'] ?? 0,
      modelVersion:   map['model_version'],
      timestamp:      DateTime.parse(map['timestamp']),
    );
  }
}
