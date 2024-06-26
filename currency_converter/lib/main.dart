import 'package:currency_converter/providers/currency_provider.dart';
import 'package:currency_converter/services/country_from_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/currency_converter_screen.dart';
import 'currency_codes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkModeEnabled') ?? false;
  String currency = prefs.getString('favoriteCurrency') ?? "";
  runApp(MainApp(isDarkMode: isDarkMode, currency: currency,));

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
                getCurrencyCode(WidgetsBinding
                    .instance.platformDispatcher.locale.countryCode
                    .toString()), "current location", currencyTo),
      ),
    ], child: const MainApp()),
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
    return const MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: CurrencyConverter(),
    );

    home:
    CurrencyConverter();
    )
  }
}
