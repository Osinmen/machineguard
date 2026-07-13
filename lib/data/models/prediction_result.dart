import 'package:flutter/material.dart';
import 'package:machine_guard/core/theme/app_theme.dart';


enum RiskLevel { healthy, atRisk, critical }

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

  bool get isCritical => status == 'CRITICAL';

  Color get alertColor => isCritical ? AppColors.red : AppColors.orange;

  IconData get alertIcon => isCritical
      ? Icons.error_outline
      : Icons.warning_amber_outlined;
}

class PredictionResult {
  final String machineId;
  final int prediction;
  final double riskProbability;
  final double riskPercentage;
  final RiskLevel riskLevel;
  final String recommendation;
  final List<SensorAlert> sensorAlerts;
  final int alertCount;
  final int criticalCount;
  final int warningCount;
  final String modelVersion;
  final DateTime timestamp;

  PredictionResult({
    required this.machineId,
    required this.prediction,
    required this.riskProbability,
    required this.riskPercentage,
    required this.riskLevel,
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
      prediction:     json['prediction'],
      riskProbability: (json['risk_probability'] as num).toDouble(),
      riskPercentage:  (json['risk_percentage'] as num).toDouble(),
      riskLevel:      _parseRiskLevel(json['risk_level']),
      recommendation: json['recommendation'],
      sensorAlerts:   (json['sensor_alerts'] as List)
                          .map((a) => SensorAlert.fromJson(a))
                          .toList(),
      alertCount:     json['alert_count'] ?? 0,
      criticalCount:  json['critical_count'] ?? 0,
      warningCount:   json['warning_count'] ?? 0,
      modelVersion:   json['model_version'] ?? '1.0.0',
      timestamp:      DateTime.now(),
    );
  }

  static RiskLevel _parseRiskLevel(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL': return RiskLevel.critical;
      case 'AT_RISK':  return RiskLevel.atRisk;
      default:         return RiskLevel.healthy;
    }
  }

  Color get riskColor {
    switch (riskLevel) {
      case RiskLevel.critical: return AppColors.red;
      case RiskLevel.atRisk:   return AppColors.orange;
      case RiskLevel.healthy:  return AppColors.cyan;
    }
  }

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.critical: return 'CRITICAL';
      case RiskLevel.atRisk:   return 'AT RISK';
      case RiskLevel.healthy:  return 'HEALTHY';
    }
  }

  // Simple HEALTHY / FAULTY label
  String get statusLabel => prediction == 0 ? 'HEALTHY' : 'FAULTY';

  Color get statusColor => prediction == 0 ? AppColors.cyan : AppColors.red;

  IconData get statusIcon => prediction == 0
      ? Icons.check_circle_outline
      : Icons.cancel_outlined;

  Map<String, dynamic> toMap() => {
    'machine_id':      machineId,
    'prediction':      prediction,
    'risk_probability': riskProbability,
    'risk_percentage':  riskPercentage,
    'risk_level':      riskLevel.name,
    'recommendation':  recommendation,
    'sensor_alerts':   sensorAlerts.map((a) => {
      'sensor':      a.sensor,
      'feature_key': a.featureKey,
      'value':       a.value,
      'unit':        a.unit,
      'status':      a.status,
      'message':     a.message,
      'warn_range':  a.warnRange,
      'crit_range':  a.critRange,
    }).toList(),
    'alert_count':    alertCount,
    'critical_count': criticalCount,
    'warning_count':  warningCount,
    'model_version':  modelVersion,
    'timestamp':      timestamp.toIso8601String(),
  };

  factory PredictionResult.fromMap(Map<String, dynamic> map) {
    return PredictionResult(
      machineId:       map['machine_id'],
      prediction:      map['prediction'],
      riskProbability: map['risk_probability'],
      riskPercentage:  map['risk_percentage'],
      riskLevel:       RiskLevel.values.firstWhere((e) => e.name == map['risk_level']),
      recommendation:  map['recommendation'],
      sensorAlerts:    (map['sensor_alerts'] as List? ?? [])
                           .map((a) => SensorAlert.fromJson(a as Map<String, dynamic>))
                           .toList(),
      alertCount:      map['alert_count'] ?? 0,
      criticalCount:   map['critical_count'] ?? 0,
      warningCount:    map['warning_count'] ?? 0,
      modelVersion:    map['model_version'],
      timestamp:       DateTime.parse(map['timestamp']),
    );
  }
}