import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class CurrencyRateApi {
  static const String _baseUrl = 'https://api.frankfurter.app';

  Future<double> getExchangeRate(String fromCurrency, String toCurrency) async {
    log("API CALL");
    final response = await http.get(Uri.parse('$_baseUrl/latest?from=$fromCurrency&to=$toCurrency'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rates'][toCurrency];
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }
}