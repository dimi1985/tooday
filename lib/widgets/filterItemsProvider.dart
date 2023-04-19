import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterItemsProvider with ChangeNotifier {
  bool filterCheckedItemsEnabled = false;
  bool filterUnCheckedItemsEnabled = false;

  FilterItemsProvider() {
    _loadfilterCheckedPreference();
    _loadfilterUnCheckedPreference();
  }

  bool get isfilterCheckedItemsEnabled => filterCheckedItemsEnabled;
  bool get isfilterUnCheckedItemsEnabled => filterUnCheckedItemsEnabled;

  set isfilterCheckedEnabled(bool value) {
    filterCheckedItemsEnabled = value;
    _savefilterCheckedPreference();
    notifyListeners();
  }

  set isfilterUnCheckedeEnabled(bool value) {
    filterUnCheckedItemsEnabled = value;
    _savefilterUnCheckedPreference();
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

  void _savefilterUnCheckedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('filterToUnCkecked', filterUnCheckedItemsEnabled);
  }

  void _loadfilterUnCheckedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    filterUnCheckedItemsEnabled = prefs.getBool('filterToUnCkecked') ?? false;
    notifyListeners();
  }
}
