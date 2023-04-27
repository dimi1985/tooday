import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsEnabledProvider with ChangeNotifier {
  bool isNotificationstEnabled = false;

  NotificationsEnabledProvider() {
    _loadIsNotificationstEnabled();
  }

  bool get geIsNotificationstEnabled => isNotificationstEnabled;

  void _loadIsNotificationstEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isNotificationstEnabled = prefs.getBool('isNotificationstEnabled') ?? false;
    notifyListeners();
  }

  static void getIsNotificationstEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool('isNotificationstEnabled');
  }
}
