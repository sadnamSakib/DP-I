import 'dart:ui';
import 'package:design_project_1/models/bloodPressureModel.dart';
import 'package:design_project_1/screens/patientInterface/healthTracker/DataVisualizer.dart';
import 'package:design_project_1/screens/patientInterface/healthTracker/foodSelectionScreen.dart';
import 'package:design_project_1/screens/patientInterface/healthTracker/kidneyDiseaseTracker/utils.dart';
import 'package:design_project_1/screens/patientInterface/healthTracker/tracker.dart';
import 'package:design_project_1/screens/patientInterface/healthTracker/waterTracker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:design_project_1/services/trackerServices/healthTrackerService.dart';

import '../../../../models/UrineModel.dart';
import '../../../../models/weightModel.dart';
import '../bloodPressureTrackerScreen.dart';
import '../weightTracker.dart';
import 'UrineTracker.dart';

class KidneyTracker extends StatefulWidget {
  const KidneyTracker({super.key});

  @override
  State<KidneyTracker> createState() => _KidneyTrackerState();

}
class measurement{
  String name;
  String icon;
  measurement(this.name, this.icon);
}
class _KidneyTrackerState extends State<KidneyTracker> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<measurement> Measurements = [(measurement('Protein', 'assets/images/food.png')), measurement('Blood Pressure', 'assets/images/bloodPressure.png'), measurement('Weight', 'assets/images/weight.png'), measurement('Urine', 'assets/images/urine.png'), measurement('Water', 'assets/images/water.png')];
  String proteinIntake = '0';
  String waterIntake = '0';
  String bloodPressure = '0/0';
  String weight = '0';
  String urine = '0';
  @override
  void initState() {
    loadProteinData();
    loadWaterData();
    loadBloodPressureData();
    loadWeightData();
    loadUrineData();
  }

  void loadData(){
    print("ekhane ashe");
    loadProteinData();
    loadWaterData();
    loadBloodPressureData();
    loadWeightData();
    loadUrineData();
  }
  void loadProteinData() async {
    print(formattedDate);
    double proteinData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getProteinDataWithDate(formattedDate);
    print(proteinData.toString());
    setState(() {
      proteinIntake = proteinData.toString() + 'g';
    });
  }
  void loadWaterData() async {
    int waterData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getWaterDataWithDate(formattedDate);
    setState(() {
      waterIntake = waterData.toString() + 'ml';
    });
  }
  void loadBloodPressureData() async {
    List<BloodPressure> bpData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getBPDataWithDate(formattedDate);
    setState(() {
      if(bpData.length > 0)
      bloodPressure = bpData.last.systolic.toString() + '/' + bpData[0].diastolic.toString();
      else bloodPressure = '0/0';
    });
  }
  void loadWeightData() async {
    Weight weightData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getWeightDataWithDate(formattedDate);
    setState(() {
      weight = weightData.beforeMeal.toString() + 'kg' + ' / ' + weightData.afterMeal.toString() + 'kg';
    });


  }
  void loadUrineData() async{
    List<Urine> urineData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getUrineDataWithDate(formattedDate);
    double totalUrineVolume = 0.0;
    for(Urine u in urineData){
      totalUrineVolume += u.volume;
    }
    setState(() {
      urine = totalUrineVolume.toString() + 'ml';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Kidney Disease Tracker'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Tracker() ));
          },
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),
        child: Column(
          children: <Widget>[
            // Weekly Calendar
            Container(
              // Adjust the height as needed
              color: Colors.grey[200],
                child: TableCalendar(
                  firstDay: kFirstDay,
                  lastDay: DateTime.now(),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    // Use `selectedDayPredicate` to determine which day is currently selected.
                    // If this returns true, then `day` will be marked as selected.

                    // Using `isSameDay` is recommended to disregard
                    // the time-part of compared DateTime objects.
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      // Call `setState()` when updating the selected day
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;

                      });
                      setState(() {

                        formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
                      loadData();
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      // Call `setState()` when updating calendar format
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    // No need to call `setState()` here
                    _focusedDay = focusedDay;
                  },
                ),
              ),

            // Visualizer
            Container(
              height: 200, // Adjust the height as needed
              color: Colors.blue[50],
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  // VisualizerWidget(), // Your custom visualizer widget
                  // VisualizerWidget(),
                  // VisualizerWidget(),
                  Padding(padding: EdgeInsets.all(10)),
                  DataVisualizer(data: proteinIntake, title: 'Protein Intake', circleColor: Colors.blue, radius: 50.0),
                  Padding(padding: EdgeInsets.all(10)),
                  DataVisualizer(title: 'Water Intake', data: waterIntake, circleColor: Colors.red, radius: 50.0),
                  Padding(padding: EdgeInsets.all(10)),
                  DataVisualizer(data: bloodPressure, title:'Blood Pressure', circleColor: Colors.green, radius: 50.0),
                  Padding(padding: EdgeInsets.all(10)),
                  DataVisualizer(data : weight, title: 'Weight', circleColor: Colors.grey, radius: 50.0),
                  Padding(padding: EdgeInsets.all(10)),
                  DataVisualizer(data: urine, title: 'Urine', circleColor: Colors.purple, radius: 50.0),
                  Padding(padding: EdgeInsets.all(10)),

                  // Add more VisualizerWidget() as needed
                ],
              ),
            ),




            // Fitness Measures
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children:[
                  for (measurement measure in Measurements)
                    GestureDetector(
                      onTap: () {
                        if (measure.name == 'Protein') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FoodSelectionScreen()),
                          );
                        } else if (measure.name == 'Water') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WaterTrackerPage()),
                          );
                        } else if (measure.name == 'Blood Pressure') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BloodPressureTracker()),
                          );
                        }
                        else if (measure.name == 'Weight') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WeightTracker()),
                          );
                        }
                        else if (measure.name == 'Urine') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UrineTracker()),
                          );
                        }
                      },
                      child: Card(
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Optional: Add border radius
                          child: Stack(
                            children: [
                              // Image (takes 70% of the card)
                              FractionallySizedBox(
                                heightFactor: 0.7,
                                widthFactor: 1.0,
                                child: Image.asset(
                                  measure.icon, // Access the image URL from the measurement object
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              // White background for the name
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      measure.name,
                                      style: TextStyle(fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ]

            ),
                    ),
          ],
        ),
      ),
    );
  }
}


