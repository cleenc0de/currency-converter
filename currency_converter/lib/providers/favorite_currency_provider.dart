import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCurrencyProvider extends ChangeNotifier {
  late String favoriteCurrency;

  FavoriteCurrencyProvider(String currency) {
    favoriteCurrency = currency;
  }

  void setFavoriteCurrency(String currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    favoriteCurrency = currency;
    prefs.setString('favoriteCurrency', favoriteCurrency);
    notifyListeners();
  }
}