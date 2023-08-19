import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimePeriodicProvider with ChangeNotifier {
  bool isTimePeriodicEnabled = false;

  TimePeriodicProvider() {
    _loadTimePeriodicEnabled();
  }

  bool get timePeriodicEnabled => isTimePeriodicEnabled;

  void _loadTimePeriodicEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isTimePeriodicEnabled = prefs.getBool('isTimePeriodicEnabled') ?? false;
    notifyListeners();
  }

  void updateTimePeriodic(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isTimePeriodicEnabled = value;
    prefs.setBool('isTimePeriodicEnabled', value);
    notifyListeners();
  }
}
