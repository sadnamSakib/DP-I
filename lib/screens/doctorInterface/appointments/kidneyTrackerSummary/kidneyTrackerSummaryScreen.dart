import 'package:design_project_1/screens/doctorInterface/appointments/kidneyTrackerSummary/waterSummaryScreen.dart';
import 'package:flutter/material.dart';

import '../../../../components/barChart/barChartComponent.dart';
import '../../../../components/barChart/bar_graph.dart';
class KidneyTrackerSummaryScreen extends StatefulWidget {
   // final patientId;
  // const KidneyTrackerSummaryScreen({super.key, this.patientId});
  KidneyTrackerSummaryScreen({super.key});
  List<double> weeklySummary =[4.40, 2.50, 42.42, 10.50, 100.20, 88.99, 90.10];
  @override
  State<KidneyTrackerSummaryScreen> createState() => _KidneyTrackerSummaryScreenState();
}

class _KidneyTrackerSummaryScreenState extends State<KidneyTrackerSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kidney Tracker Summary'),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: SizedBox(
            height: 400,
            child: BarGraph(
              weeklySummary: widget.weeklySummary,
            )
        ),
      ),
    );
  }
}
