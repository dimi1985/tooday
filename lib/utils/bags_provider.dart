import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BagsProvider with ChangeNotifier {
  bool _isBagsProviderEnabled = false;

  BagsProvider() {
    _loadBagsProviderPreference();
  }

  bool get isBagsProviderEnabled => _isBagsProviderEnabled;

  set isBagsProviderEnabled(bool value) {
    _isBagsProviderEnabled = value;
    _saveBagsProviderPreference();
    notifyListeners();
  }

  void _saveBagsProviderPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBagsProviderEnabled', _isBagsProviderEnabled);
  }

  void _loadBagsProviderPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isBagsProviderEnabled = prefs.getBool('isBagsProviderEnabled') ?? false;
    notifyListeners();
  }
}
