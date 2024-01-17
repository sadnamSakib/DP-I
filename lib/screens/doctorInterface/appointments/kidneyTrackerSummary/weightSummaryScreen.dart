import 'package:flutter/material.dart';
import '../../../../components/barChart/bar_graph.dart';
import '../../../../models/weightModel.dart';
import '../../../../services/trackerServices/healthTrackerService.dart';
class WeightSummary extends StatefulWidget {
  final patientId;
  final days;
  const WeightSummary({super.key, this.patientId, this.days});

  @override
  State<WeightSummary> createState() => _WeightSummaryState();
}

class _WeightSummaryState extends State<WeightSummary> {
  List<double> weightBeforeMealList = [];
  List<double> weightAfterMealList = [];
  double highestWeight = 0;
  double lowestWeight = 1000;
  @override
  void initState() {
    super.initState();
    getWeightData();
  }

  Future<void> getWeightData() async {
    List<Weight> weightData =
    await healthTrackerService(uid: widget.patientId).getPastWeightData(widget.days);

    setState(() {
      for(int i = 0; i < weightData.length; i++){
        weightBeforeMealList.add(weightData[i].beforeMeal);
        weightAfterMealList.add(weightData[i].afterMeal);

        if(weightData[i].beforeMeal > highestWeight){
          highestWeight = weightData[i].beforeMeal;
        }
        if(weightData[i].beforeMeal < lowestWeight){
          lowestWeight = weightData[i].beforeMeal;
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
            child: Text("Weight Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
          ),
          weightAfterMealList.isEmpty
              ? CircularProgressIndicator()
              : SizedBox(
            height: 300,
            width: 400,
            child: BarGraph(
              values1: weightAfterMealList,
              values2 : weightBeforeMealList,
            ),
          ),
          SizedBox(height: 20),
          Text("Highest Weight: $highestWeight kg",
          style: TextStyle(fontSize: 20)),
          Text("Lowest Weight: $lowestWeight kg",
    style: TextStyle(fontSize: 20)),
        ],
    );
  }
}
