import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../models/bloodPressureModel.dart';
import '../../../../models/weightModel.dart';
import '../../../../services/healthTrackerService.dart';
class BloodPressureSummary extends StatefulWidget {
  final patientId;
  const BloodPressureSummary({super.key, this.patientId});

  @override
  State<BloodPressureSummary> createState() => _BloodPressureSummaryState();
}

class _BloodPressureSummaryState extends State<BloodPressureSummary> {
  List<double> systolicList = [];
  List<double> diastolicList = [];
  @override
  void initState() {
    super.initState();
    getBloodPressureData();
  }

  Future<void> getBloodPressureData() async {
    List<BloodPressure> weightData =
    await healthTrackerService(uid: widget.patientId).getPastBpData(7);

    setState(() {
      for(int i = 0; i < weightData.length; i++){
        systolicList.add(weightData[i].systolic.toDouble());
        diastolicList.add(weightData[i].diastolic.toDouble());
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: systolicList.isEmpty // Check if the data is empty
            ? CircularProgressIndicator() // Show loading indicator
            : SizedBox(
          height: 400,
          child: BarGraph(
            values1: systolicList,
            values2 : diastolicList,
          ),
        ),
      ),
    );
  }
}
