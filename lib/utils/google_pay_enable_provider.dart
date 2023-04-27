import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GooglePayEnabledProvider with ChangeNotifier {
  bool isGooglePaytEnabled = false;

  GooglePayEnabledProvider() {
    _loadIsGooglePaytEnabled();
  }

  bool get geIsGooglePaytEnabled => isGooglePaytEnabled;

  void _loadIsGooglePaytEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isGooglePaytEnabled = prefs.getBool('isGooglePayEnabled') ?? false;
    notifyListeners();
  }

  static void getGooglePaytEnabledgBoolean() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool('isGooglePayEnabled');
  }
}
