import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../services/trackerServices/healthTrackerService.dart';
class ProteinSummary extends StatefulWidget {
  final patientId;
  final days;
  const ProteinSummary({super.key, this.patientId, this.days});

  @override
  State<ProteinSummary> createState() => _ProteinSummaryState();
}

class _ProteinSummaryState extends State<ProteinSummary> {
  List<double> proteinList = [];
  double averageProteinIntake = 0;
  String averageProtein = "";
  @override
  void initState() {
    super.initState();
    getProteinData();
  }

  Future<void> getProteinData() async {
    List<double> proteinData =
    await healthTrackerService(uid: widget.patientId).getPastProteinData(widget.days);
    setState(() {
      proteinList = proteinData;
      for(var data in proteinList){
        averageProteinIntake += data;
        print("Ekhane protein print hobe");
        print(averageProteinIntake);
      }
      averageProteinIntake = (averageProteinIntake / proteinList.length);
averageProtein = averageProteinIntake.toStringAsFixed(2);
    });
  }

  Widget build(BuildContext context) {
    return Column(
          children: <Widget>[
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text("Protein Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
        proteinList.isEmpty // Check if the data is empty
            ? CircularProgressIndicator() // Show loading indicator
            : SizedBox(
          height: 300,
          width: 400,
          child: BarGraph(
            values1: proteinList,
            values2 : List.filled(proteinList.length, 0),
          ),
        ),
            SizedBox(height: 20),
            Text("Average Protein Intake: $averageProtein g", style: TextStyle(fontSize: 20)),
    ],
      );
  }
}
