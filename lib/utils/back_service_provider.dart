import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundServiceProvider with ChangeNotifier {
  bool _isServiceEnabled = false;

  BackgroundServiceProvider() {
    _loadServiceEnabled();
  }

  bool get isServiceEnabled => _isServiceEnabled;

  void _loadServiceEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isServiceEnabled = prefs.getBool('isServiceEnabled') ?? false;
    notifyListeners();
  }

  void toggleService(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isServiceEnabled = value;
    prefs.setBool('isServiceEnabled', value);
    notifyListeners();
  }
}
