import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkThemeEnabled = false;

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeData get currentTheme =>
      _isDarkThemeEnabled ? ThemeData.dark() : ThemeData.light();

  bool get isDarkThemeEnabled => _isDarkThemeEnabled;

  set isDarkThemeEnabled(bool value) {
    _isDarkThemeEnabled = value;
    _saveThemePreference();
    notifyListeners();
  }

  void _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkThemeEnabled', _isDarkThemeEnabled);
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkThemeEnabled = prefs.getBool('isDarkThemeEnabled') ?? false;
    notifyListeners();
  }
}
