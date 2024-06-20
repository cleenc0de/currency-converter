import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CurrencyRateApi {
  static const String _baseUrl = 'https://api.frankfurter.app';

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

  Future<List<String>> getHistory(String fromCurrency, String toCurrency) async {
    DateTime now = DateTime.now();
    print(DateFormat.yMMMd().format(DateTime.now()));
    DateTime oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    log("startdate: $oneYearAgo, enddate: $now");
    final response = await http.get(Uri.parse(
        '$_baseUrl/${DateFormat('yyyy-MM-dd').format(oneYearAgo)}..${DateFormat('yyyy-MM-dd').format(now)}?from=$fromCurrency&to=$toCurrency'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<String> rates = [];

      data['rates'].forEach((date, rate) {
        rates.add(rate[toCurrency].toString());
      });

      return rates;
    } else {
      throw Exception('Failed to load currency history');
    }
  }
}
