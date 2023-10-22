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
  List<BloodPressure> bloodPressureList = [];

  List<Urine> urineList = [];
  List<double> waterIntakeList = [];
  List<Weight> weightList = [];

  @override
  void initState() {
    super.initState();
    getBloodPressureData();
    getUrineData();
    getWaterIntakeData();
    getWeightData();
  }

  Future<void> getBloodPressureData() async {
    List<BloodPressure> bpList =
    await healthTrackerService(uid: widget.patientId).getPastBpData(7);

    setState(() {
      bloodPressureList = bpList;
      print(bloodPressureList.toString());
    });
  }


  Future<void> getUrineData() async {
    List<Urine> u =
    await healthTrackerService(uid: widget.patientId).getPastUrineData(7);
    setState(() {
      urineList = u;
      print(urineList.toString());
    });
  }

  Future<void> getWaterIntakeData() async {
    List<int> waterIntakeData =
    await healthTrackerService(uid: widget.patientId).getPastWaterData(7);
    setState(() {
      waterIntakeList = waterIntakeData.cast<double>();
      print(waterIntakeList.toString());
    });
  }

  Future<void> getWeightData() async {
    List<Weight> weightData =
    await healthTrackerService(uid: widget.patientId).getPastWeightData(7);
    setState(() {
      weightList = weightData;
      print(weightList.toString());
    });
  }

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
