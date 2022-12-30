import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:variacao_ativo_flutter/core/data/datasource/active_remote_datasource.dart';

class PriceVariationChart extends StatelessWidget {
  final List<PriceData> data;

  const PriceVariationChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = data
        .map((priceData) =>
            FlSpot(priceData.timestamp.toDouble(), priceData.variation))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Variação de Preço'),
      ),
      body: LineChart(
        LineChartData(
          backgroundColor: Colors.white,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Color.fromARGB(255, 55, 65, 77),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF01579B),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF01579B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
