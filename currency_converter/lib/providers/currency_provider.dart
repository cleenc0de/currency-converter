import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrencyFrom;
  String _actualCurrencyFrom;
  String _selectedCurrencyTo;
  String _actualCurrencyTo;

  CurrencyProvider(this._selectedCurrencyFrom, this._selectedCurrencyTo, this._actualCurrencyTo) : _actualCurrencyFrom = _selectedCurrencyFrom;

  String get selectedCurrencyFrom => _selectedCurrencyFrom;
  String get selectedCurrencyTo => _selectedCurrencyTo;
  String get actualCurrencyTo => _actualCurrencyTo;
  String get actualCurrencyFrom => _actualCurrencyFrom;

  void setSelectedCurrencyFrom(String value) {
    _selectedCurrencyFrom = value;
    if (value != "current location") {
      _actualCurrencyFrom = value;
    }
    notifyListeners();
  }

  void setSelectedCurrencyTo(String value) {
    _selectedCurrencyTo = value;
    if (value != "current location") {
      _actualCurrencyTo = value;
    }
    notifyListeners();
  }
}
