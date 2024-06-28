import 'package:flutter/material.dart';
import '../services/country_from_location.dart';
import '../currency_codes.dart';

class CurrencyProvider with ChangeNotifier {
  String _selectedCurrencyFrom;
  String _actualCurrencyFrom;
  String _selectedCurrencyTo;
  String _actualCurrencyTo;

  CurrencyProvider(this._selectedCurrencyFrom, this._selectedCurrencyTo, this._actualCurrencyTo)
      : _actualCurrencyFrom = _selectedCurrencyFrom;

  String get selectedCurrencyFrom => _selectedCurrencyFrom;
  String get selectedCurrencyTo => _selectedCurrencyTo;
  String get actualCurrencyTo => _actualCurrencyTo;
  String get actualCurrencyFrom => _actualCurrencyFrom;

  void setSelectedCurrencyFrom(String value) async {
    _selectedCurrencyFrom = value;
    if (value == "current location") {
      String countryCode = await getCountryFromLocation();
      _actualCurrencyFrom = getCurrencyCode(countryCode);
    } else {
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
