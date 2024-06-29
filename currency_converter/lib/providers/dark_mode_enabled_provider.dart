import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkModeEnabledProvider extends ChangeNotifier {
  late bool darkModeEnabled;

  DarkModeEnabledProvider(bool isDarkMode) {
    darkModeEnabled = isDarkMode;
  }

  void switchDarkModeEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    darkModeEnabled = !darkModeEnabled;
    prefs.setBool('darkModeEnabled',  darkModeEnabled);
    notifyListeners();
  }
}
