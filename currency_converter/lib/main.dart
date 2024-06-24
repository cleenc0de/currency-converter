import 'package:currency_converter/providers/currency_provider.dart';
import 'package:currency_converter/services/country_from_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/currency_converter_screen.dart';
import 'currency_codes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String countryCode = await getCountryFromLocation();
  String currencyTo = getCurrencyCode(countryCode);

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => CurrencyProvider(
            getCurrencyCode(WidgetsBinding
                .instance.platformDispatcher.locale.countryCode
                .toString()), "current location", currencyTo),
      ),
    ], child: const MainApp()),
  );
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
