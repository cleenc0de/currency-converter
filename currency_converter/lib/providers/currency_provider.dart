import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrencyFrom;
  String _actualCurrencyFrom;
  String _selectedCurrencyTo;
  String _actualCurrencyTo;
  final String _currentLocation;

  CurrencyProvider(this._selectedCurrencyFrom, this._selectedCurrencyTo, this._actualCurrencyTo)
      : _actualCurrencyFrom = _selectedCurrencyFrom, _currentLocation = _actualCurrencyTo;

  String get selectedCurrencyFrom => _selectedCurrencyFrom;
  String get selectedCurrencyTo => _selectedCurrencyTo;
  String get actualCurrencyTo => _actualCurrencyTo;
  String get actualCurrencyFrom => _actualCurrencyFrom;
  String get currentLocation => _currentLocation;

  void setSelectedCurrencyFrom(String value) async {
    _selectedCurrencyFrom = value;
    if (value == "current location") {
      _actualCurrencyFrom = _currentLocation;
    } else {
      _actualCurrencyFrom = value;
    }
    notifyListeners();
  }

  void setSelectedCurrencyTo(String value) {
    _selectedCurrencyTo = value;
    if (value == "current location") {
      _actualCurrencyTo = _currentLocation;
    } else {
      _actualCurrencyTo = value;
    }
    notifyListeners();
  }
}
