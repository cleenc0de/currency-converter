import 'dart:developer';

import 'package:currency_converter/currency_codes.dart';
import 'package:currency_converter/widgets/currency_drop_down_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/currency_rate_api.dart';


//TODO: Add DropDown current location
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CurrencyConverter(),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  CurrencyConverterState createState() => CurrencyConverterState();
}

class CurrencyConverterState extends State<CurrencyConverter> {
  String _selectedCurrencyFrom = getCurrencyCode(WidgetsBinding.instance.platformDispatcher.locale.countryCode.toString()); // current smartphone setting
  String _selectedCurrencyTo = 'EUR'; // TODO: current location
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // TODO: _selectedCurrencyTo = getCurrencyCode(getCurrentLocation());
    _fromController.addListener(_onFromChanged);
    _toController.addListener(_onToChanged);
  }

  void _onFromChanged() async {
    if (_fromController.text.isEmpty) return;
    double fromValue = double.parse(_fromController.text);
    double rate = await getExchangeRate(_selectedCurrencyFrom, _selectedCurrencyTo);
    double toValue = fromValue * rate;
    _toController.value = TextEditingValue(text: toValue.toStringAsFixed(2));
  }

  void _onToChanged() async {
    if (_toController.text.isEmpty) return;
    double toValue = double.parse(_toController.text);
    double rate = await getExchangeRate(_selectedCurrencyTo, _selectedCurrencyFrom);
    double fromValue = toValue * rate;
    //_fromController.value = TextEditingValue(text: fromValue.toStringAsFixed(2));
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
              "1 $_selectedCurrencyFrom corresponds", //TODO: don't hardcode exchange rate
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 18),
            Text(
              "1,09 $_selectedCurrencyTo", //TODO: don't hardcode exchange rate
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
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'^\d+(.)*\d?'))],
                  ),
                ),
                const SizedBox(width: 10),
                CurrencyDropDownWidget(
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrencyFrom = value!;
                      _onFromChanged();
                    });
                  },
                  initialValue: _selectedCurrencyFrom,
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "your smartphone language settings",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
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
                      _selectedCurrencyTo = value!;
                      _onToChanged();
                    });
                  },
                  initialValue: _selectedCurrencyTo,
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
                  onPressed: () {},
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
