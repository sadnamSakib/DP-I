import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../services/healthTrackerService.dart';
class WaterSummary extends StatefulWidget {
  final patientId;
  const WaterSummary({super.key, this.patientId});

  @override
  State<WaterSummary> createState() => _WaterSummaryState();
}

class _WaterSummaryState extends State<WaterSummary> {
  List<double> waterList = [];
  @override
  void initState() {
    super.initState();
    getWaterData();
  }

  Future<void> getWaterData() async {
    List<double> waterData =
    (await healthTrackerService(uid: widget.patientId).getPastWaterData(7)).cast<double>();
    setState(() {
      waterList = waterData;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: waterList.isEmpty // Check if the data is empty
            ? CircularProgressIndicator() // Show loading indicator
            : SizedBox(
          height: 400,
          child: BarGraph(
            values1: waterList,
            values2 : List.filled(waterList.length, 10),
          ),
        ),
      ),
    );
  }
}
