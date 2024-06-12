import 'package:flutter/material.dart';

class CurrencyDropDownWidget extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final String initialValue;

  const CurrencyDropDownWidget({
    super.key,
    required this.onChanged,
    this.initialValue = 'USD',
  });

  @override
  CurrencyDropDownWidgetState createState() => CurrencyDropDownWidgetState();
}

class CurrencyDropDownWidgetState extends State<CurrencyDropDownWidget> {
  final List<String> _currencyCodes = ['USD', 'EUR', 'GBP', 'JPY', 'CNY'];
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: _selectedCurrency,
      onSelected: (String? newValue) {
        setState(() {
          _selectedCurrency = newValue;
        });
        widget.onChanged(newValue);
      },
      dropdownMenuEntries: _currencyCodes.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
        );
      }).toList(),
    );
  }
}