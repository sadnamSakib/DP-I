import 'package:flutter/material.dart';

import '../../../../components/barChart/bar_graph.dart';
import '../../../../models/UrineModel.dart';
import '../../../../services/trackerServices/healthTrackerService.dart';
class UrineSummary extends StatefulWidget {
  final patientId;
  final days;
  UrineSummary({super.key, this.patientId, this.days});

  @override
  State<UrineSummary> createState() => _UrineSummaryState();
}

class _UrineSummaryState extends State<UrineSummary> {
  List<double> urineList = [];
  double averageUrineVolume = 0;
  Map<String, double> dayBasedUrineVolume = {};
  Map<String, int> colorFrequency = {};
  String mostFrequentColor = "";
  @override
  void initState() {
    super.initState();
    getUrineData();
  }

  Future<void> getUrineData() async {
    List<Urine> urineData =
    await healthTrackerService(uid: widget.patientId).getPastUrineData(widget.days);

    setState(() {
      for (int i = 0; i < urineData.length; i++) {
        urineList.add(urineData[i].volume);

        if (dayBasedUrineVolume[urineData[i].date] == null) {
          dayBasedUrineVolume[urineData[i].date] = urineData[i].volume;
        } else {
          dayBasedUrineVolume[urineData[i].date] = (dayBasedUrineVolume[urineData[i].date] ?? 0) + urineData[i].volume;
        }
        if (colorFrequency[urineData[i].color] == null) {
          colorFrequency[urineData[i].color] = 1;
        } else {
          colorFrequency[urineData[i].color] = (colorFrequency[urineData[i].color] ?? 0) + 1;
        }

      }
      for(var data in dayBasedUrineVolume.values){
        averageUrineVolume += data;

      }
      averageUrineVolume = averageUrineVolume / dayBasedUrineVolume.length;
      int max = 0;
      for(var data in colorFrequency.entries){
        if(data.value > max){
          max = data.value;
          mostFrequentColor = data.key;
        }
      }

    });
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text("Urine Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
        ),
        if (urineList.isEmpty)
          CircularProgressIndicator()
        else
          SizedBox(
            height: 300,
            width: 400,
            child: BarGraph(
              values1: urineList,
              values2: List.filled(urineList.length, 0),
            ),
          ),
        SizedBox(height: 20),
        Text("Average Urine Volume: $averageUrineVolume", style: TextStyle(fontSize: 20)),
        SizedBox(height: 20),
        Text("Most Frequent Colored Urine: $mostFrequentColor",style: TextStyle(fontSize: 20)),
      ],
    );

  }
}
