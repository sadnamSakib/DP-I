import 'dart:math';

import 'package:design_project_1/components/barChart/bar_graph.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../components/barChart/barChartComponent.dart'; // For the chart

class WaterSummary extends StatefulWidget {
  List<Color> get availableColors => const <Color>[
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.indigo,
  ];

  final Color barBackgroundColor =
  Colors.white70.withOpacity(0.3);
  final Color barColor = Colors.white70;
  final Color touchedBarColor = Colors.green;
   WaterSummary({super.key});



  @override
  State<WaterSummary> createState() => _WaterSummaryState();
}
class _WaterSummaryState extends State<WaterSummary> {
  String _selectedFormat = 'Weekly';

  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Summary'),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField(
                value: _selectedFormat,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFormat = newValue!;
                  });
                },
                items: ['Weekly', 'Monthly']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Water Intake',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1000 ml', // Replace with actual average water intake
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Card(
            // child :
            //   BarGraph(),

          ),
        ],
      ),
    );
  }

}

