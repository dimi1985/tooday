import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepeatNotificationsProvider with ChangeNotifier {
  bool isRepeatNotifications = false;

  RepeatNotificationsProvider() {
    _loadRepeatNotifications();
  }

  bool get repeatNotifications => isRepeatNotifications;

  void _loadRepeatNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRepeatNotifications = prefs.getBool('repeatNotifications') ?? false;
    notifyListeners();
  }

  void updateRepeatNotifications(bool repeat) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRepeatNotifications = repeat;
    prefs.setBool('repeatNotifications', repeat);
    notifyListeners();
  }
}
