import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSignInProvider with ChangeNotifier {
  bool isSignedIn = false;

  UserSignInProvider() {
    _loadUserSignedInStatus();
    notifyListeners();
  }

  bool get getIsUserSignin => isSignedIn;

  set setIsUserSignin(bool value) {
    isSignedIn = value;
    notifyListeners(); // Add this line to notify listeners
  }

  void _loadUserSignedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSignedIn = prefs.getBool('isSignedIn') ?? false;
    notifyListeners();
  }

  static void getIsUserSigninBoolean() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool('isSignedIn');
  }
}
