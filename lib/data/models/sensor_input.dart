class SensorInput {
  final String machineId;
  final String machineType;
  final int installationYear;
  final double temperatureC;
  final double vibrationMms;
  final double powerConsumptionKw;
  final double operationalHours;
  final int lastMaintenanceDaysAgo;
  final int maintenanceHistoryCount;
  final int failureHistoryCount;
  final double oilLevelPct;
  final double coolantLevelPct;
  final bool aiSupervision;
  final int aiOverrideEvents;
  final double remainingUsefulLifeDays;
  final int errorCodesLast30Days;
  final double soundDb;

  SensorInput({
    required this.machineId,
    required this.machineType,
    required this.installationYear,
    required this.temperatureC,
    required this.vibrationMms,
    required this.powerConsumptionKw,
    required this.operationalHours,
    required this.lastMaintenanceDaysAgo,
    required this.maintenanceHistoryCount,
    required this.failureHistoryCount,
    required this.oilLevelPct,
    required this.coolantLevelPct,
    required this.aiSupervision,
    required this.aiOverrideEvents,
    required this.remainingUsefulLifeDays,
    required this.errorCodesLast30Days,
    required this.soundDb,
  });

  Map<String, dynamic> toJson() => {
    'machine_id': machineId,
    'machine_type': machineType,
    'installation_year': installationYear,
    'temperature_c': temperatureC,
    'vibration_mms': vibrationMms,
    'power_consumption_kw': powerConsumptionKw,
    'operational_hours': operationalHours,
    'last_maintenance_days_ago': lastMaintenanceDaysAgo,
    'maintenance_history_count': maintenanceHistoryCount,
    'failure_history_count': failureHistoryCount,
    'oil_level_pct': oilLevelPct,
    'coolant_level_pct': coolantLevelPct,
    'ai_supervision': aiSupervision,
    'ai_override_events': aiOverrideEvents,
    'remaining_useful_life_days': remainingUsefulLifeDays,
    'error_codes_last_30_days': errorCodesLast30Days,
    'sound_db': soundDb,
  };
}
