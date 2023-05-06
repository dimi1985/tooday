import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireStoreCountProvider with ChangeNotifier {
  int firestoreCount = 0;

  FireStoreCountProvider() {
    _loadFireStoreCount();
  }

  int get geIsShoppingtEnabled => firestoreCount;

  void _loadFireStoreCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    firestoreCount = prefs.getInt('firestoreCount') ?? 0;
    notifyListeners();
  }

  static void getFireStoreCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getInt('firestoreCount');
  }
}
