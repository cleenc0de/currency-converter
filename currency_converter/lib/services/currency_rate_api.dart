import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

abstract class CurrencyRateApi {
  Future<double> getExchangeRate(String fromCurrency, String toCurrency);
  Future<Map<String, dynamic>> getHistory(String fromCurrency, String toCurrency);
}

class CurrencyRateApiImpl extends CurrencyRateApi {
  static const String _baseUrl = 'https://api.frankfurter.app';

  @override
  Future<double> getExchangeRate(String fromCurrency, String toCurrency) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/latest?from=$fromCurrency&to=$toCurrency'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rates'][toCurrency];
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }

  @override
  Future<Map<String, dynamic>> getHistory(String fromCurrency, String toCurrency) async {
    DateTime now = DateTime.now();
    DateTime oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    Uri uri = Uri.parse(
        '$_baseUrl/${DateFormat('yyyy-MM-dd').format(oneYearAgo)}..${DateFormat('yyyy-MM-dd').format(now)}?from=$fromCurrency&to=$toCurrency');
    log("$uri");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<String> rates = [];
      final List<int> months = [];

      data['rates'].forEach((date, rate) {
        rates.add(rate[toCurrency].toString());
        DateTime dateTime = DateTime.parse(date);
        months.add(dateTime.month);
      });

      log("rates: $rates, months: $months");

      return {'rates': rates, 'months': months};
    } else {
      throw Exception('Failed to load currency history');
    }
  }
}
