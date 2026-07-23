class SensorInput {
  final String? machineId;
  final String machineType;
  final String operatingMode;
  final double vibrationRms;
  final double temperatureMotor;
  final double currentPhaseAvg;
  final double pressureLevel;
  final double rpm;
  final double hoursSinceMaintenance;
  final double ambientTemp;

  SensorInput({
    this.machineId,
    required this.machineType,
    required this.operatingMode,
    required this.vibrationRms,
    required this.temperatureMotor,
    required this.currentPhaseAvg,
    required this.pressureLevel,
    required this.rpm,
    required this.hoursSinceMaintenance,
    required this.ambientTemp,
  });

  Map<String, dynamic> toJson() => {
    'machine_id': machineId,
    'machine_type': machineType,
    'operating_mode': operatingMode,
    'vibration_rms': vibrationRms,
    'temperature_motor': temperatureMotor,
    'current_phase_avg': currentPhaseAvg,
    'pressure_level': pressureLevel,
    'rpm': rpm,
    'hours_since_maintenance': hoursSinceMaintenance,
    'ambient_temp': ambientTemp,
  };
}
