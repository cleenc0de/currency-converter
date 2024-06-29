import 'package:currency_converter/providers/currency_provider.dart';
import 'package:currency_converter/providers/dark_mode_enabled_provider.dart';
import 'package:currency_converter/providers/favorite_currency_provider.dart';
import 'package:currency_converter/services/country_from_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/currency_converter_screen.dart';
import 'currency_codes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkModeEnabled') ?? false;
  String currency = prefs.getString('favoriteCurrency') ?? "";

  String countryCode = await getCountryFromLocation();
  String currencyTo = getCurrencyCode(countryCode);

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => DarkModeEnabledProvider(isDarkMode)),
      ChangeNotifierProvider(
          create: (context) => FavoriteCurrencyProvider(currency)),
      ChangeNotifierProvider(
        create: (context) =>
            CurrencyProvider(
                currency.isEmpty?getCurrencyCode(WidgetsBinding
                    .instance.platformDispatcher.locale.countryCode
                    .toString()):currency, "current location", currencyTo),
      ),
    ], child: MainApp(isDarkMode: isDarkMode, currency: currency,)),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.isDarkMode, required this.currency});

  final bool isDarkMode;
  final String currency;

  @override
  Widget build(BuildContext context) {
    bool darkModeEnabled = context
        .watch<DarkModeEnabledProvider>()
        .darkModeEnabled;
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: const CurrencyConverter(),
    );
  }
}
