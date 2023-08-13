import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTimingProvider with ChangeNotifier {
  int _notificationInterval = 15; // Default interval in minutes

  NotificationTimingProvider() {
    _loadNotificationInterval();
  }

  int get notificationInterval => _notificationInterval;

  void _loadNotificationInterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _notificationInterval = prefs.getInt('notificationInterval') ?? 15;
    notifyListeners();
  }

  void updateNotificationInterval(int interval) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _notificationInterval = interval;
    prefs.setInt('notificationInterval', interval);
    notifyListeners();
  }
}
