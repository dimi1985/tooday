import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HourSelectionProvider with ChangeNotifier {
  TimeOfDay _selectedHour = TimeOfDay.now();

  HourSelectionProvider() {
    _loadSelectedHour();
  }

  TimeOfDay get selectedHour => _selectedHour;

  void _loadSelectedHour() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('selectedHourHour') ?? TimeOfDay.now().hour;
    final minute = prefs.getInt('selectedHourMinute') ?? TimeOfDay.now().minute;
    _selectedHour = TimeOfDay(hour: hour, minute: minute);
    notifyListeners();
  }

  void updateSelectedHour(TimeOfDay newHour) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedHour = newHour;
    prefs.setInt('selectedHourHour', newHour.hour);
    prefs.setInt('selectedHourMinute', newHour.minute);
    notifyListeners();
  }
}
