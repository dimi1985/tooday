import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterItemsProvider with ChangeNotifier {
  bool filterCheckedItemsEnabled = false;

  FilterItemsProvider() {
    _loadfilterCheckedPreference();
  }

  bool get isfilterEnabled => filterCheckedItemsEnabled;

  set isfilterCheckedEnabled(bool value) {
    filterCheckedItemsEnabled = value;
    _savefilterCheckedPreference();
    notifyListeners();
  }

  void _savefilterCheckedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('filterToCkecked', filterCheckedItemsEnabled);
  }

  void _loadfilterCheckedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    filterCheckedItemsEnabled = prefs.getBool('filterToCkecked') ?? false;
    notifyListeners();
  }
}
