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
import '../../../../services/trackerServices/healthTrackerService.dart';
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
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Map<String, int> durationMap = {
    'Past Week': 7,
    'Past Month': 30,
    'Past Year': 365,
  };
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen to page changes and update the current page.
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

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
        backgroundColor: Colors.pink.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.pink.shade50],
          ),
        ),
        child: Column(
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
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  ProteinSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
                  BloodPressureSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
                  WeightSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
                  UrineSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),
                  WaterSummary(patientId: widget.patientId, days: durationMap[selectedDuration]),

                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage ? Colors.blue : Colors.grey,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );

  }
}
