import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterItemsProvider with ChangeNotifier {
  bool showCheckedItems = false;

  FilterItemsProvider() {
    _loadfilterCheckedPreference();
  }

  bool get isShowGetCheckedItems => showCheckedItems;

  void _loadfilterCheckedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showCheckedItems = prefs.getBool('showCheckedItems') ?? false;
    notifyListeners();
  }
}
