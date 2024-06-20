import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrencyFrom;
  String _selectedCurrencyTo;

  CurrencyProvider(this._selectedCurrencyFrom, this._selectedCurrencyTo);

  String get selectedCurrencyFrom => _selectedCurrencyFrom;
  String get selectedCurrencyTo => _selectedCurrencyTo;

  void setSelectedCurrencyFrom(String value) {
    _selectedCurrencyFrom = value;
    notifyListeners();
  }

  void setSelectedCurrencyTo(String value) {
    _selectedCurrencyTo = value;
    notifyListeners();
  }
}
