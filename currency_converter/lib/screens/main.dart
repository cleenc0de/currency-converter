
import 'dart:developer';

import 'package:currency_converter/currency_codes.dart';
import 'package:currency_converter/providers/providers.dart';
import 'package:currency_converter/screens/settings.dart';
import 'package:currency_converter/widgets/currency_drop_down_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/country_from_location.dart';
import '../services/currency_rate_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkModeEnabled') ?? false;
  String currency = prefs.getString('favoriteCurrency') ?? "";
  runApp(MainApp(isDarkMode: isDarkMode, currency: currency,));
}

class MainApp extends StatelessWidget {
  final bool isDarkMode;
  final String currency;
  const MainApp({super.key, required this.isDarkMode, required this.currency});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DarkModeEnabledProvider(isDarkMode)),
        ChangeNotifierProvider(create: (context) => FavoriteCurrencyProvider(currency)),
      ],
      child: Builder(
        builder: (context) {
          bool darkModeEnabled = context.watch<DarkModeEnabledProvider>().darkModeEnabled;
          return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
            ),
            themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
            home: CurrencyConverter(),
          );
        }
      ),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  CurrencyConverterState createState() => CurrencyConverterState();
}

class CurrencyConverterState extends State<CurrencyConverter> {
  String _selectedCurrencyFrom = getCurrencyCode(WidgetsBinding
      .instance.platformDispatcher.locale.countryCode
      .toString()); // current smartphone setting
  String _selectedCurrencyTo = "EUR";
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final CurrencyRateApi _currencyRateApi = CurrencyRateApi(); // Instance der API
  bool _isConverting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCurrencyTo();
    _fromController.addListener(_onFromChanged);
    _toController.addListener(_onToChanged);
  }

  Future<void> _initializeCurrencyTo() async {
    String countryCode = await getCountryFromLocation();
    setState(() {
      _selectedCurrencyTo = getCurrencyCode(countryCode);
    });
  }

  void _onFromChanged() async {
    if (_isConverting || _fromController.text.isEmpty) return;
    _isLoading = true;
    _isConverting = true;
    try {
      double fromValue = double.parse(_fromController.text);
      double rate = await _currencyRateApi.getExchangeRate(_selectedCurrencyFrom, _selectedCurrencyTo);
      double toValue = fromValue * rate;
      _toController.value = TextEditingValue(text: toValue.toStringAsFixed(2));
    } catch (e) {
      log('Error in _onFromChanged: $e');
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
      double rate = await _currencyRateApi.getExchangeRate(_selectedCurrencyTo, _selectedCurrencyFrom);
      double fromValue = toValue * rate;
      _fromController.value = TextEditingValue(text: fromValue.toStringAsFixed(2));
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
    var size = MediaQuery.sizeOf(context);
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
              "1 $_selectedCurrencyFrom corresponds",
              //TODO: don't hardcode exchange rate
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
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+(.)*\d?'))
                    ],
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
                  disabledValue: _selectedCurrencyTo,
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
                  disabledValue: _selectedCurrencyFrom,
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
                  onPressed: () {
                    showBarModalBottomSheet(
                      enableDrag: true,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      context: context,
                      builder: (context) => const Settings()
                    );
                  },
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