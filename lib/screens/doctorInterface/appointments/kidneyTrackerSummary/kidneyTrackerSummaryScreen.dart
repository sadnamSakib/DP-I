import 'package:design_project_1/screens/doctorInterface/appointments/kidneyTrackerSummary/proteinSummaryScreen.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/kidneyTrackerSummary/urineSummaryScreen.dart';
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
  String selectedDuration = 'Past Week';
  Map<String, int> durationMap = {
    'Past Week': 7,
    'Past Month': 30,
    'Past Year': 365,
  };

  void updateDays(String? duration) {
    if (duration != null) {
      setState(() {
        selectedDuration = duration;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kidney Tracker Summary'),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Choose Duration Format:',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(width: 20.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButton<String>(
                    value: selectedDuration,
                    onChanged: (String? newValue) {
                      updateDays(newValue);
                    },
                    items: <String>[
                      'Past Week',
                      'Past Month',
                      'Past Year',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 600,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                UrineSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
                WeightSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
                WaterSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
                BloodPressureSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
                ProteinSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
              ],
            ),
          ),
        ],
      ),
    );

  }
}
