import 'package:currency_converter/country_from_location.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: getCountryFromLocation(),
            builder: (context, snapshot) {
              return snapshot.hasData?Text(snapshot.data.toString()):Text("Country not found");
            },
          )
        ),
      ),
    );
  }
}
