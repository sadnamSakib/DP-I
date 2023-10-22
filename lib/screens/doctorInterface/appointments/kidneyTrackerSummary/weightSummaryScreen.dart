import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../models/weightModel.dart';
import '../../../../services/healthTrackerService.dart';
class WeightSummary extends StatefulWidget {
  final patientId;
  const WeightSummary({super.key, this.patientId});

  @override
  State<WeightSummary> createState() => _WeightSummaryState();
}

class _WeightSummaryState extends State<WeightSummary> {
  List<double> weightBeforeMealList = [];
  List<double> weightAfterMealList = [];
  @override
  void initState() {
    super.initState();
    getWeightData();
  }

  Future<void> getWeightData() async {
    List<Weight> weightData =
    await healthTrackerService(uid: widget.patientId).getPastWeightData(7);

    setState(() {
      for(int i = 0; i < weightData.length; i++){
        weightBeforeMealList.add(weightData[i].beforeMeal);
        weightAfterMealList.add(weightData[i].afterMeal);
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: weightAfterMealList.isEmpty // Check if the data is empty
            ? CircularProgressIndicator() // Show loading indicator
            : SizedBox(
          height: 400,
          child: BarGraph(
            values1: weightAfterMealList,
            values2 : weightBeforeMealList,
          ),
        ),
      ),
    );
  }
}
