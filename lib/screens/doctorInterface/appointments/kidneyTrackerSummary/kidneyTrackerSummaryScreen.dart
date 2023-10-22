import 'package:design_project_1/screens/doctorInterface/appointments/kidneyTrackerSummary/waterSummaryScreen.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/kidneyTrackerSummary/weightSummaryScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this
import '../../../../components/barChart/bar_graph.dart';
import '../../../../models/UrineModel.dart';
import '../../../../models/bloodPressureModel.dart';
import '../../../../models/weightModel.dart';
import '../../../../services/healthTrackerService.dart';
import 'bloodPuressureSummary.dart';

class KidneyTrackerSummaryScreen extends StatefulWidget {
  final patientId;

  KidneyTrackerSummaryScreen({Key? key, this.patientId}) : super(key: key);

  @override
  State<KidneyTrackerSummaryScreen> createState() =>
      _KidneyTrackerSummaryScreenState();
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
        child:// Show loading indicator
             SizedBox(
          height: 400,
          child: WeightSummary(
            patientId: widget.patientId
          ),
        ),
      ),
    );
  }
}
