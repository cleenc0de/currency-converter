import 'dart:developer';
import 'package:currency_converter/providers/currency_rate_api_provider.dart';
import 'package:currency_converter/screens/history_panel.dart';
import 'package:currency_converter/screens/settings.dart';
import 'package:currency_converter/widgets/currency_drop_down_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../services/currency_rate_api.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  CurrencyConverterState createState() => CurrencyConverterState();
}

class CurrencyConverterState extends State<CurrencyConverter> {
  late CurrencyProvider currencyProvider;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  late CurrencyRateApi _currencyRateApi;
  double _rate = 1.0;
  bool _isConverting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    _currencyRateApi = Provider.of<CurrencyRateApiProvider>(context, listen: false).api;
    _fromController.addListener(_onFromChanged);
    _toController.addListener(_onToChanged);
    _updateExchangeRate();
  }

  void _updateExchangeRate() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _rate = currencyProvider.actualCurrencyFrom != currencyProvider.actualCurrencyTo?await _currencyRateApi.getExchangeRate(
        currencyProvider.actualCurrencyFrom,
        currencyProvider.actualCurrencyTo,
      ):1.0;
      _onFromChanged();
    } catch (e) {
      log('Error in _updateExchangeRate: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFromChanged() {
    if (_isConverting || _fromController.text.isEmpty) return;

    setState(() {
      _isConverting = true;
    });

    double fromValue = double.tryParse(_fromController.text) ?? 0.0;
    if (currencyProvider.actualCurrencyFrom ==
        currencyProvider.actualCurrencyTo) {
      _toController.value =
          TextEditingValue(text: fromValue.toString());
    } else {
      double toValue = fromValue * _rate;
      _toController.value = TextEditingValue(text: toValue.toString());
    }

    setState(() {
      _isConverting = false;
    });
  }

  void _onToChanged() {
    if (_isConverting || _toController.text.isEmpty) return;

    setState(() {
      _isConverting = true;
    });

    double toValue = double.tryParse(_toController.text) ?? 0.0;
    if (currencyProvider.actualCurrencyFrom ==
        currencyProvider.actualCurrencyTo) {
      _fromController.value =
          TextEditingValue(text: toValue.toString());
    } else {
      double fromValue = toValue / _rate;
      _fromController.value =
          TextEditingValue(text: fromValue.toString());
    }

    setState(() {
      _isConverting = false;
    });
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "1.0 ${currencyProvider.actualCurrencyFrom} corresponds",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 18),
                Text(
                  _isLoading
                      ? "Loading..."
                      : "$_rate ${currencyProvider.actualCurrencyTo}",
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
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,4}'))
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    CurrencyDropDownWidget(
                      onChanged: (value) async {
                        setState(() {
                          currencyProvider.setSelectedCurrencyFrom(value!);
                        });
                        _updateExchangeRate();
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
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,4}'))
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    CurrencyDropDownWidget(
                      onChanged: (value) {
                        setState(() {
                          currencyProvider.setSelectedCurrencyTo(value!);
                        });
                        _updateExchangeRate();
                      },
                      initialValue: currencyProvider.selectedCurrencyTo,
                      disabledValue: currencyProvider.selectedCurrencyFrom,
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Space for the IconButtons
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      showBarModalBottomSheet(
                        enableDrag: true,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        context: context,
                        builder: (context) => const Settings(),
                      );
                    },
                    iconSize: 50,
                  ),
                  IconButton.filled(
                    icon: const Icon(Icons.show_chart),
                    onPressed: () {
                      showBarModalBottomSheet(
                        context: context,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        builder: (BuildContext context) {
                          return const CurrencyHistoryPanel();
                        },
                      );
                    },
                    iconSize: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
