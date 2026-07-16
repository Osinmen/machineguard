class AppConstants {
  static const String appName       = 'MachineGuard';
  static const String appVersion    = '1.0.0';
  static const String defaultApiUrl = 'https://machinefaultdetection.onrender.com';
  static const String apiV1         = '/api/v1';

  // Risk thresholds — must match backend config.py
  static const double highRiskThreshold     = 0.50;
  static const double criticalRiskThreshold = 0.75;

  // SharedPreferences keys
  static const String prefApiUrl = 'api_url';

  // DB
  static const String dbName       = 'machineguard.db'; //machine name database 
  static const int    dbVersion    = 1;
  static const String tableHistory = 'prediction_history';

  // Real machine types from training dataset
  static const List<String> machineTypes = [
    'CMM',
    'CNC Lathe',
    'Conveyor Belt',
    'Industrial Chiller',
    'Injection Molder',
    'Labeler',
    'Pump',
    'Vacuum Packer',
  ];
}