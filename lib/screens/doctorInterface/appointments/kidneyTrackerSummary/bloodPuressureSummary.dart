import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../models/bloodPressureModel.dart';
import '../../../../models/weightModel.dart';
import '../../../../services/healthTrackerService.dart';
class BloodPressureSummary extends StatefulWidget {
  final patientId;
  final days;
  const BloodPressureSummary({super.key, this.patientId, this.days});

  @override
  State<BloodPressureSummary> createState() => _BloodPressureSummaryState();
}

class _BloodPressureSummaryState extends State<BloodPressureSummary> {
  List<double> systolicList = [];
  List<double> diastolicList = [];
  double highestSystolic = 0;
  double lowestSystolic = 1000;
  double highestDiastolic = 0;
  double lowestDiastolic = 1000;
  @override
  void initState() {
    super.initState();
    getBloodPressureData();
  }

  Future<void> getBloodPressureData() async {
    List<BloodPressure> weightData =
    await healthTrackerService(uid: widget.patientId).getPastBpData(widget.days);

    setState(() {
      for(int i = 0; i < weightData.length; i++){
        systolicList.add(weightData[i].systolic.toDouble());
        diastolicList.add(weightData[i].diastolic.toDouble());

        if(weightData[i].systolic > highestSystolic){
          highestSystolic = weightData[i].systolic.toDouble();
        }
        if(weightData[i].systolic < lowestSystolic){
          lowestSystolic = weightData[i].systolic.toDouble();
        }
        if(weightData[i].diastolic > highestDiastolic){
          highestDiastolic = weightData[i].diastolic.toDouble();
        }
        if(weightData[i].diastolic < lowestDiastolic){
          lowestDiastolic = weightData[i].diastolic.toDouble();
        }
      }
    });
  }

  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          SizedBox(height: 20),
          Text("Blood Pressure Summary"),
          systolicList.isEmpty // Check if the data is empty
              ? CircularProgressIndicator() // Show loading indicator
              : SizedBox(
            height: 300,
            width: 400,
            child: BarGraph(
              values1: systolicList,
              values2 : diastolicList,
            ),
          ),
          SizedBox(height: 20),
          Text("Highest Systolic: $highestSystolic mmHg"),
          Text("Lowest Systolic: $lowestSystolic mmHg"),
          Text("Highest Diastolic: $highestDiastolic mmHg"),
          Text("Lowest Diastolic: $lowestDiastolic mmHg"),
        ],
    );
  }
}
