import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepeatNotificationsProvider with ChangeNotifier {
  bool _repeatNotifications = false;

  RepeatNotificationsProvider() {
    _loadRepeatNotifications();
  }

  bool get repeatNotifications => _repeatNotifications;

  void _loadRepeatNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _repeatNotifications = prefs.getBool('repeatNotifications') ?? false;
    notifyListeners();
  }

  void updateRepeatNotifications(bool repeat) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _repeatNotifications = repeat;
    prefs.setBool('repeatNotifications', repeat);
    notifyListeners();
  }
}
