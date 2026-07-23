class AppConstants {
  static const String appName       = 'MachineGuard';
  static const String appVersion    = '1.0.0';
  static const String defaultApiUrl = 'https://machinefaultdetection.onrender.com';
  static const String apiV1         = '/api/v1';

  // SharedPreferences keys
  static const String prefApiUrl = 'api_url';

  // DB
  static const String dbName       = 'machineguard.db'; //machine name database 
  static const int    dbVersion    = 3;
  static const String tableHistory = 'prediction_history';

  // Categories the model was actually trained on — must match the
  // backend's VALID_MACHINE_TYPES / VALID_OPERATING_MODES exactly,
  // since they're baked into the fitted OneHotEncoder.
  static const List<String> machineTypes = [
    'CNC',
    'Compressor',
    'Pump',
    'Robotic Arm',
  ];

  static const List<String> operatingModes = [
    'idle',
    'normal',
    'peak',
  ];

  // All 5 possible fault-type outputs from the model
  static const List<String> faultTypes = [
    'healthy',
    'bearing',
    'electrical',
    'hydraulic',
    'motor_overheat',
  ];
}