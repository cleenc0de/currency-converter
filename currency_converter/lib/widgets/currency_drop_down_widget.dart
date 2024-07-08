import 'package:flutter/material.dart';

class CurrencyDropDownWidget extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  final String initialValue;
  final String disabledValue;

  const CurrencyDropDownWidget({
    super.key,
    required this.onChanged,
    required this.initialValue,
    required this.disabledValue,
  });

  @override
  CurrencyDropDownWidgetState createState() => CurrencyDropDownWidgetState();
}

class CurrencyDropDownWidgetState extends State<CurrencyDropDownWidget> {
  final List<String> _currencyCodes = [
    'current location',
    'AUD',
    'BGN',
    'BRL',
    'CAD',
    'CHF',
    'CNY',
    'CZK',
    'DKK',
    'EUR',
    'GBP',
    'HKD',
    'HUF',
    'IDR',
    'ILS',
    'INR',
    'ISK',
    'JPY',
    'KRW',
    'MXN',
    'MYR',
    'NOK',
    'NZD',
    'PHP',
    'PLN',
    'RON',
    'SEK',
    'SGD',
    'THB',
    'TRY',
    'USD',
    'ZAR'
  ];

  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.initialValue;
  }

  @override
  void didUpdateWidget(CurrencyDropDownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedCurrency = widget.initialValue;
      });
    }
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
          enabled: value != widget.disabledValue,
        );
      }).toList(),
    );
  }
}
