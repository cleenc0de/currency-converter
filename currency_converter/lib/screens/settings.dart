import 'package:currency_converter/data/providers.dart';
import 'package:currency_converter/widgets/currency_drop_down_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    bool darkModeEnabled = context.watch<DarkModeEnabledProvider>().darkModeEnabled;
    String favoriteCurrency = context.watch<FavoriteCurrencyProvider>().favoriteCurrency;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Wrap(
            children: <Widget>[
              const Text('Settings', style: TextStyle(fontSize: 32),),
              const SizedBox(height: 75,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(darkModeEnabled?"Light Mode":"Dark Mode", style: const TextStyle(fontSize: 20),),
                  IconButton.filledTonal(
                    iconSize: 20,
                    onPressed: () {
                      context.read<DarkModeEnabledProvider>().switchDarkModeEnabled();
                    },
                    icon: Icon(darkModeEnabled?Icons.light_mode:Icons.dark_mode)
                  ),
                ],
              ),
              const SizedBox(height: 50,),
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