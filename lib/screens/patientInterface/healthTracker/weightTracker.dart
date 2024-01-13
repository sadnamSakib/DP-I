import 'package:flutter/material.dart';
import 'package:vertical_weight_slider/vertical_weight_slider.dart';
import 'package:design_project_1/services/trackerServices/healthTrackerService.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/weightModel.dart';
import 'kidneyDiseaseTracker/kidneyTracker.dart';
class WeightTracker extends StatefulWidget {
  const WeightTracker({super.key});

  @override
  State<WeightTracker> createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  late WeightSliderController _controller;
  double _beforeMealWeight = 0.0; // Initial weight
  double _afterMealWeight = 0.0; // Initial weight
  bool _isBeforeMealMode = true; // Initially, we're in "Before Meal" mode
  @override
  void initState() {
    super.initState();
    _controller = WeightSliderController(initialWeight: 60, minWeight: 0, interval: 0.1);
    loadWeightData();
  }
  void loadWeightData() async {
    Weight weightData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getWeightData();
    setState(() {
      _beforeMealWeight = weightData.beforeMeal;
      _afterMealWeight = weightData.afterMeal;
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _updateWeight(double weight) {
    if (_isBeforeMealMode) {
      setState(() {
        _beforeMealWeight = weight;
      });
    } else {
      setState(() {
        _afterMealWeight = weight;
      });
    }

  }
Future<void> saveWeight() async {
    Weight weight = Weight(beforeMeal: _beforeMealWeight, afterMeal: _afterMealWeight);
    await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid)
        .updateWeightData(weight);
    loadWeightData();
  }
  void _switchMode(bool isBeforeMealMode) {
    setState(() {
      _isBeforeMealMode = isBeforeMealMode;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Tracker'),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KidneyTracker() ));
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // colors: [Colors.white70, Colors.blue.shade200],
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 80,
              child: Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.transparent),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Before Meal Weight: $_beforeMealWeight kg',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            Container(
              height: 80,
              child: Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),

                  side: BorderSide(color: Colors.transparent),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'After Meal Weight: $_afterMealWeight kg',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'Slide to select your weight',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Weight: ${_isBeforeMealMode ? _beforeMealWeight : _afterMealWeight} kg',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
            VerticalWeightSlider(
              controller: _controller,
              decoration: const PointerDecoration(
                width: 130.0,
                height: 3.0,
                largeColor: Color(0xFF898989),
                mediumColor: Color(0xFFC5C5C5),
                smallColor: Color(0xFFF0F0F0),
                gap: 30.0,
              ),
              onChanged: (weight) {
                _updateWeight(weight);
              },
              indicator: Container(
                height: 3.0,
                width: 200.0,
                alignment: Alignment.centerLeft,
                color: Colors.red[300],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _switchMode(true); // Switch to "Before Meal" mode
                  },
                  style: ElevatedButton.styleFrom(primary: _isBeforeMealMode ? Colors.green : null),
                  child: Text('Before Meal'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _switchMode(false); // Switch to "After Meal" mode
                  },
                  style: ElevatedButton.styleFrom(primary: !_isBeforeMealMode ? Colors.green : null),
                  child: Text('After Meal'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  saveWeight();
                  // This is where you can save the weights to your database or perform any other action.
                  double beforeMealWeight = _beforeMealWeight;
                  double afterMealWeight = _afterMealWeight;
                },
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                ),
                child: Text('Add Weight'),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
