import 'package:currency_converter/data/providers.dart';
import 'package:currency_converter/widgets/currency_drop_down_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool darkModeEnabled = context.watch<DarkModeEnabledProvider>().darkModeEnabled;
    String favoriteCurrency = context.watch<FavoriteCurrencyProvider>().favoriteCurrency;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 32),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(darkModeEnabled?"Light Mode":"Dark Mode", style: const TextStyle(fontSize: 20),),
                IconButton(
                  iconSize: 20,
                  onPressed: () {
                    context.read<DarkModeEnabledProvider>().switchDarkModeEnabled();
                  },
                  icon: Icon(darkModeEnabled?Icons.light_mode:Icons.dark_mode)
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Favorite Currency", style: TextStyle(fontSize: 20),),
                CurrencyDropDownWidget(
                  onChanged: (value) {
                    context.read<FavoriteCurrencyProvider>().setFavoriteCurrency(value.toString());
                  },
                  initialValue: favoriteCurrency,
                  disabledValue: "",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
}