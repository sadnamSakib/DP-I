import 'package:design_project_1/components/barChart/bar_data.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarGraph extends StatelessWidget {
  final List weeklySummary;
  const BarGraph({super.key,
    required this.weeklySummary,});

  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(
      sunAmount: weeklySummary[0],
      monAmount: weeklySummary[1],
      tueAmount: weeklySummary[2],
      wedAmount: weeklySummary[3],
      thuAmount: weeklySummary[4],
      friAmount: weeklySummary[5],
      satAmount: weeklySummary[6],
    );
    myBarData.initializeBarData();
    return BarChart(
      BarChartData(
        maxY: 100,
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
                    toY: data.y,
                    color: Colors.blue,
                    width: 20,
                    borderRadius: BorderRadius.circular(10),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
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
