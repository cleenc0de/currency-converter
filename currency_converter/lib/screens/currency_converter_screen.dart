import 'dart:developer';
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
  dynamic currencyProvider;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final CurrencyRateApi _currencyRateApi = CurrencyRateApi();
  double _rate = 1.0;
  bool _isConverting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    _fromController.addListener(_onFromChanged);
    _toController.addListener(_onToChanged);
  }

  void _onFromChanged() async {
    if (_isConverting || _fromController.text.isEmpty) return;
    _isLoading = true;
    _isConverting = true;
    try {
      double fromValue = double.parse(_fromController.text);
      if (currencyProvider.actualCurrencyFrom == currencyProvider.actualCurrencyTo) {
        _toController.value = TextEditingValue(text: fromValue.toStringAsFixed(2));
      } else {
        _rate = await _currencyRateApi.getExchangeRate(
          currencyProvider.actualCurrencyFrom,
          currencyProvider.actualCurrencyTo,
        );
        double toValue = fromValue * _rate;
        _toController.value = TextEditingValue(text: toValue.toStringAsFixed(2));
      }
    } catch (e) {
      log('\n Error in _onFromChanged: $e\n');
    } finally {
      setState(() {
        _isConverting = false;
        _isLoading = false;
      });
    }
  }

  void _onToChanged() async {
    if (_isConverting || _toController.text.isEmpty) return;
    _isLoading = true;
    _isConverting = true;
    try {
      double toValue = double.parse(_toController.text);
      if (currencyProvider.actualCurrencyFrom == currencyProvider.actualCurrencyTo) {
        _fromController.value = TextEditingValue(text: toValue.toStringAsFixed(2));
      } else {
        _rate = await _currencyRateApi.getExchangeRate(
          currencyProvider.actualCurrencyTo,
          currencyProvider.actualCurrencyFrom,
        );
        double fromValue = toValue * _rate;
        _fromController.value = TextEditingValue(text: fromValue.toStringAsFixed(2));
      }
    } catch (e) {
      log('Error in _onToChanged: $e');
    } finally {
      setState(() {
        _isConverting = false;
        _isLoading = false;
      });
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
              "1.0 ${currencyProvider.actualCurrencyFrom} corresponds",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 18),
            Text(
              "$_rate ${currencyProvider.actualCurrencyTo}",
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
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+(.)*\d?')) //TODO: fix code
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                CurrencyDropDownWidget(
                  onChanged: (value) async {
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
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    showBarModalBottomSheet(
                        enableDrag: true,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        context: context,
                        builder: (context) => const Settings());
                  },
                  iconSize: 50,
                ),
                IconButton.filled(
                  icon: const Icon(Icons.show_chart),
                  onPressed: () {
                    showBarModalBottomSheet(
                      context: context,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      builder: (BuildContext context) {
                        return const CurrencyHistoryPanel();
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
