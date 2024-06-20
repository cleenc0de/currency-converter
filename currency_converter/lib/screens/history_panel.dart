import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/currency_rate_api.dart';
import '../providers/currency_provider.dart';

class CurrencyHistoryPanel extends StatefulWidget {
  const CurrencyHistoryPanel({super.key});

  @override
  CurrencyHistoryPanelState createState() => CurrencyHistoryPanelState();
}

class CurrencyHistoryPanelState extends State<CurrencyHistoryPanel> {
  List<FlSpot> _dataPoints = [];
  bool _isLoading = true;
  final CurrencyRateApi _currencyRateApi = CurrencyRateApi();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    var currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
    try {
      final rates = await _currencyRateApi.getHistory(
          currencyProvider.selectedCurrencyFrom,
          currencyProvider.selectedCurrencyTo);
      setState(() {
        _dataPoints = rates.asMap().entries.map((entry) {
          int index = entry.key;
          double value = double.parse(entry.value);
          return FlSpot(index.toDouble(), value);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 300,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Text('Currency History',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _dataPoints,
                          isCurved: true,
                          barWidth: 3,
                          color: Colors.blue,
                          belowBarData: BarAreaData(show: false),
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
