import 'package:currency_converter/widgets/currency_drop_down_widget.dart';
import 'package:flutter/material.dart';

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
  String _selectedCurrencyFrom = 'EUR';
  String _selectedCurrencyTo = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Währungsrechner',
          style: TextStyle(fontSize: 32),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "1 $_selectedCurrencyFrom entspricht",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 18),
            Text(
              "1,09 $_selectedCurrencyTo",
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                CurrencyDropDownWidget(
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrencyFrom = value!;
                    });
                  },
                  initialValue: _selectedCurrencyFrom,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                CurrencyDropDownWidget(
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrencyTo = value!;
                    });
                  },
                  initialValue: _selectedCurrencyTo,
                ),
              ],
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "Dein aktueller Standort",
                textAlign: TextAlign.right,
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
