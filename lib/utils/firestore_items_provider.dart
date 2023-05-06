import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireStoreItemsProvider with ChangeNotifier {
  bool fireStoreNewItemsNeedSync = false;

  FireStoreItemsProvider() {
    _loadFireStoreNewItemsNeedSync();
  }

  bool get getFireStoreNewItemsNeedSync => fireStoreNewItemsNeedSync;

  void _loadFireStoreNewItemsNeedSync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fireStoreNewItemsNeedSync =
        prefs.getBool('fireStoreNewItemsNeedSync') ?? false;
    notifyListeners();
  }
}
