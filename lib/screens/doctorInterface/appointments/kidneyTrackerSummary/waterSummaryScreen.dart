import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../services/trackerServices/healthTrackerService.dart';
class WaterSummary extends StatefulWidget {
  final patientId;
  final days;
  const WaterSummary({super.key, this.patientId, this.days});

  @override
  State<WaterSummary> createState() => _WaterSummaryState();
}

class _WaterSummaryState extends State<WaterSummary> {
  List<double> waterList = [];
  double averageWaterIntake = 0;
  String averageWater = "";
  @override
  void initState() {
    super.initState();
    getWaterData();
  }

  Future<void> getWaterData() async {
    List<double> waterData = await healthTrackerService(uid: widget.patientId).getPastWaterData(widget.days);
    setState(() {
      waterList = waterData;
      for(var data in waterList){
        averageWaterIntake += data;
      }
      averageWaterIntake = (averageWaterIntake / waterList.length);
      averageWater = averageWaterIntake.toStringAsFixed(2);
    });
  }

  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text("Water Intake Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
          ),
          waterList.isEmpty
              ? CircularProgressIndicator()
              : SizedBox(
            height: 300,
            width: 400,
            child: BarGraph(
              values1: waterList,
              values2 : List.filled(waterList.length, 0),
            ),
          ),
          SizedBox(height: 20),
          Text("Average Water Intake: $averageWater ml ", style: TextStyle(fontSize: 20)),
        ],
    );
  }
}
