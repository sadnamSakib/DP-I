import 'package:design_project_1/components/barChart/bar_data.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarGraph extends StatelessWidget {
  final List <double> values1;
  final List <double> values2;
  const BarGraph({super.key,
    required this.values1, required this.values2});

  @override
  Widget build(BuildContext context) {
    double maxSummaryValue = values1.isNotEmpty ? values1.reduce((a, b) => a > b ? a : b) : 0.0;
    maxSummaryValue = maxSummaryValue + maxSummaryValue * 0.1;
    BarData myBarData = BarData(
      values1 : values1,
      values2 : values2,
    );
    myBarData.initializeBarData();
    return BarChart(
      BarChartData(
        maxY: maxSummaryValue,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))
        ),
        barGroups: myBarData.barData
            .map(
              (data) => BarChartGroupData(
            x: data.x,
                barRods: [
                  BarChartRodData(

                    toY: data.y1,
                    color: Colors.green.shade900,
                    width: 10,
                    borderRadius: BorderRadius.circular(10),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxSummaryValue,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  BarChartRodData(
                    toY: data.y2,
                    color: Colors.red,
                    width: 10,
                    borderRadius: BorderRadius.circular(10),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ]
          ),
        )
            .toList(),
      ),

    );
  }
}
