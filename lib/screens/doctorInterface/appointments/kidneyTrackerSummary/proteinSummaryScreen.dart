import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../services/healthTrackerService.dart';
class ProteinSummary extends StatefulWidget {
  final patientId;
  const ProteinSummary({super.key, this.patientId});

  @override
  State<ProteinSummary> createState() => _ProteinSummaryState();
}

class _ProteinSummaryState extends State<ProteinSummary> {
  List<double> proteinList = [];
  @override
  void initState() {
    super.initState();
    getProteinData();
  }

  Future<void> getProteinData() async {
    List<double> proteinData =
    await healthTrackerService(uid: widget.patientId).getPastProteinData(7);
    setState(() {
      proteinList = proteinData;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: proteinList.isEmpty // Check if the data is empty
            ? CircularProgressIndicator() // Show loading indicator
            : SizedBox(
          height: 400,
          child: BarGraph(
            values1: proteinList,
            values2 : List.filled(proteinList.length, 10),
          ),
        ),
      ),
    );
  }
}
