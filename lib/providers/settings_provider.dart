import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:machine_guard/core/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  String _apiUrl = AppConstants.defaultApiUrl;

  String get apiUrl => _apiUrl;

 Future<void> resetToDefault() async {
  _apiUrl = AppConstants.defaultApiUrl;
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(AppConstants.prefApiUrl);
  notifyListeners();
}

  Future<void> updateApiUrl(String url) async {
    _apiUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefApiUrl, url);
    notifyListeners();
  }
}
