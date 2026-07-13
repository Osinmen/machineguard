import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:machine_guard/core/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  String _apiUrl = AppConstants.defaultApiUrl;

  String get apiUrl => _apiUrl;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _apiUrl = prefs.getString(AppConstants.prefApiUrl) ?? AppConstants.defaultApiUrl;
    notifyListeners();
  }

  Future<void> updateApiUrl(String url) async {
    _apiUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefApiUrl, url);
    notifyListeners();
  }
}
