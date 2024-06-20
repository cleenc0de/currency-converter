import 'dart:developer';

import 'package:currency_converter/currency_codes.dart';
import 'package:currency_converter/screens/history_panel.dart';
import 'package:currency_converter/widgets/currency_drop_down_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../services/country_from_location.dart';
import '../services/currency_rate_api.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  CurrencyConverterState createState() => CurrencyConverterState();
}

class CurrencyConverterState extends State<CurrencyConverter> {
  dynamic currencyProvider;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final CurrencyRateApi _currencyRateApi =
  CurrencyRateApi();
  bool _isConverting = false;
  bool _isLoading = false; // TODO: wait until current location is loading

  @override
  void initState() {
    super.initState();
    currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    _initializeCurrencyTo();
    _fromController.addListener(_onFromChanged);
    _toController.addListener(_onToChanged);
  }

  Future<void> _initializeCurrencyTo() async {
    String countryCode = await getCountryFromLocation();
    currencyProvider.setSelectedCurrencyTo(getCurrencyCode(countryCode));
  }

  void _onFromChanged() async {
    if (_isConverting || _fromController.text.isEmpty) return;
    _isLoading = true;
    _isConverting = true;
    try {
      double fromValue = double.parse(_fromController.text);
      double rate = await _currencyRateApi.getExchangeRate(
          currencyProvider.selectedCurrencyFrom,
          currencyProvider.selectedCurrencyTo);
      double toValue = fromValue * rate;
      _toController.value = TextEditingValue(text: toValue.toStringAsFixed(2));
    } catch (e) {
      log('\n Error in _onFromChanged: $e\n');
    } finally {
      _isConverting = false;
      _isLoading = false;
    }
  }

  void _onToChanged() async {
    if (_isConverting || _toController.text.isEmpty) return;
    _isLoading = true;
    _isConverting = true;
    try {
      double toValue = double.parse(_toController.text);
      double rate = await _currencyRateApi.getExchangeRate(
          currencyProvider.selectedCurrencyTo,
          currencyProvider.selectedCurrencyFrom);
      double fromValue = toValue * rate;
      _fromController.value =
          TextEditingValue(text: fromValue.toStringAsFixed(2));
    } catch (e) {
      log('Error in _onToChanged: $e');
    } finally {
      _isConverting = false;
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Currency Calculator',
          style: TextStyle(fontSize: 32),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "1 ${currencyProvider.selectedCurrencyFrom} corresponds",
              //TODO: don't hardcode exchange rate
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 18),
            Text(
              "1,09 ${currencyProvider.selectedCurrencyTo}",
              //TODO: don't hardcode exchange rate
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fromController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+(.)*\d?'))
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                CurrencyDropDownWidget(
                  onChanged: (value) {
                    setState(() {
                      currencyProvider.setSelectedCurrencyFrom(value!);
                      _onFromChanged();
                    });
                  },
                  initialValue: currencyProvider.selectedCurrencyFrom,
                  disabledValue: currencyProvider.selectedCurrencyTo,
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 10),
                CurrencyDropDownWidget(
                  onChanged: (value) {
                    setState(() {
                      currencyProvider.setSelectedCurrencyTo(value!);
                      _onFromChanged();
                    });
                  },
                  initialValue: currencyProvider.selectedCurrencyTo,
                  disabledValue: currencyProvider.selectedCurrencyFrom,
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "your current location",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                  iconSize: 50,
                ),
                IconButton.filled(
                  icon: const Icon(Icons.show_chart),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return CurrencyHistoryPanel();
                        },
                    );
                  },
                  iconSize: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
