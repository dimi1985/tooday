import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HourBoolSelectionProvider with ChangeNotifier {
  bool isHourSelected = false;

  HourBoolSelectionProvider() {
    _loadHourSelection();
  }

  bool get hourSelected => isHourSelected;

  void _loadHourSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isHourSelected = prefs.getBool('isHourSelected') ?? false;
    notifyListeners();
  }

  void updateHourSelection(bool selected) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isHourSelected = selected;
    prefs.setBool('isHourSelected', selected);
    notifyListeners();
  }
}
