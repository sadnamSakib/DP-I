import 'package:design_project_1/components/barChart/bar_graph.dart';
import 'package:flutter/material.dart';

//Input: List of weekly expenses= [sunAmount, monAmount, tueAmount, wedAmount, thuAmount, friAmount, satAmount]
//Output: Bar chart of weekly expenses

class BarChart extends StatefulWidget {
  const BarChart({super.key});

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  List<double> weeklySummary =[4.40, 2.50, 42.42, 10.50, 100.20, 88.99, 90.10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(

          // child: BarGraph()
         ),
    );
  }
}

