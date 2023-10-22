import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../models/UrineModel.dart';
import '../../../../services/healthTrackerService.dart';
class UrineSummary extends StatefulWidget {
  final patientId;
  const UrineSummary({super.key, this.patientId});

  @override
  State<UrineSummary> createState() => _UrineSummaryState();
}

class _UrineSummaryState extends State<UrineSummary> {
  List<double> urineList = [];
  @override
  void initState() {
    super.initState();
    getUrineData();
  }

  Future<void> getUrineData() async {
    List<Urine> urineData =
    await healthTrackerService(uid: widget.patientId).getPastUrineData(7);

    setState(() {
      for(int i = 0; i < urineData.length; i++){
        urineList.add(urineData[i].volume);
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: urineList.isEmpty // Check if the data is empty
            ? CircularProgressIndicator() // Show loading indicator
            : SizedBox(
          height: 400,
          child: BarGraph(
            values1: urineList,
            values2 : List.filled(urineList.length, 10),
          ),
        ),
      ),
    );
  }
}
