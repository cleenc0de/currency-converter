import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/currency_rate_api.dart';
import '../providers/currency_provider.dart';

class CurrencyHistoryPanel extends StatefulWidget {
  static const List<String> monthsNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  const CurrencyHistoryPanel({super.key});

  @override
  CurrencyHistoryPanelState createState() => CurrencyHistoryPanelState();
}

class CurrencyHistoryPanelState extends State<CurrencyHistoryPanel> {
  List<FlSpot> _dataPoints = [];
  bool _isLoading = true;
  final CurrencyRateApi _currencyRateApi = CurrencyRateApi();
  List<int> months = [];
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  String _getMonth(int value) {
    return CurrencyHistoryPanel.monthsNames[value-1];
  }

  Future<void> _loadHistory() async {
    var currencyProvider =
    Provider.of<CurrencyProvider>(context, listen: false);
    setState(() {
      _errorMessage = "";
    });
    if (currencyProvider.actualCurrencyFrom == currencyProvider.actualCurrencyTo) {
      setState(() {
        _errorMessage = "Choose two different locations";
        _isLoading = false;
      });
      return;
    }
    try {
      final historyData = await _currencyRateApi.getHistory(
          currencyProvider.selectedCurrencyFrom,
          currencyProvider.selectedCurrencyTo);
      final rates = historyData['rates'] as List<String>;
      months = historyData['months'] as List<int>;

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
      height: 500,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : Column(
        children: [
          const Text('Currency History per year',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _dataPoints,
                    barWidth: 3,
                    color: Colors.blue,
                    belowBarData: BarAreaData(show: false),
                    dotData: const FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          interval: 4.42, // 53 (digits) : 12 (month / year)
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            String monthStr = _getMonth(months[index]);
                            return SideTitleWidget(axisSide: meta.axisSide, child: Text(monthStr));
                          }
                      )
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
