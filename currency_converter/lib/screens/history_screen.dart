import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CurrencyHistoryDialog extends StatelessWidget {
  final List<FlSpot> dataPoints;

  const CurrencyHistoryDialog({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Currency History'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: dataPoints,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
