import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingEnabledProvider with ChangeNotifier {
  bool isSoppingEnabled = false;

  ShoppingEnabledProvider() {
    _loadIsShoppingtEnabled();
  }

  bool get geIsShoppingtEnabled => isSoppingEnabled;

  void _loadIsShoppingtEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSoppingEnabled = prefs.getBool('isSoppingEnabled') ?? false;
    notifyListeners();
  }

  static void getShoppingBoolean() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool('isSoppingEnabled');
  }
}
