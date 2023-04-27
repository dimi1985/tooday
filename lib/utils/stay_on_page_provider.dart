import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StayOnPageProvider with ChangeNotifier {
  bool isStayOnEnabled = false;

  StayOnPageProvider() {
    _loadStayPreference();
  }

  bool get isStayOnPAgeEnabled => isStayOnEnabled;

  set isStayOnEnabledEnabled(bool value) {
    isStayOnEnabled = value;
    _saveStayPreference();
    notifyListeners();
  }

  void _saveStayPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stayOnAddTodoScreen', isStayOnEnabled);
  }

  void _loadStayPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isStayOnEnabled = prefs.getBool('stayOnAddTodoScreen') ?? false;
    notifyListeners();
  }
}
