import 'package:design_project_1/models/bloodPressureModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/trackerServices/healthTrackerService.dart';
import 'kidneyDiseaseTracker/kidneyTracker.dart';
class BloodPressureTracker extends StatefulWidget {
  @override
  _BloodPressureTrackerState createState() => _BloodPressureTrackerState();
}

class _BloodPressureTrackerState extends State<BloodPressureTracker> {
  List<BloodPressure> records = [];
  int systolic = 120;
  int diastolic = 80;
  @override
  void initState() {
    super.initState();
    loadBPData();
  }

  void loadBPData() async {
    List<BloodPressure> bpData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getBPData();
    setState(() {
      records = bpData;
    });
  }

  void addRecord() async{
    DateTime now = DateTime.now();
    String formattedTime = "${DateFormat('yyyy-MM-dd HH:mm').format(now)}";
    String record = "Systolic: $systolic mmHg, Diastolic: $diastolic mmHg at $formattedTime";
    setState(() {
      records.add(BloodPressure(systolic: systolic, diastolic: diastolic, time: formattedTime));
    });
    await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).updateBPData(records);
    loadBPData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Blood Pressure Tracker'),
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
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Background image with blur
            // IgnorePointer(
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: Image.asset(
            //       'assets/images/bpBackground.png', // Replace with your image path
            //       fit: BoxFit.fitWidth,
            //
            //     ),
            //   ),
            // ),
            // Blurred overlay
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    'Systolic: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    '$systolic mmHg',
                    style: TextStyle(fontSize: 24, color: Colors.red.shade900),
                  ),
                  Slider(
                    value: systolic.toDouble(),
                    min: 80,
                    max: 200,
                    divisions: 24,
                    onChanged: (value) {
                      setState(() {
                        systolic = value.toInt();
                      });
                    },
                    activeColor: Colors.red,
                    inactiveColor: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Diastolic: ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    '$diastolic mmHg',
                    style: TextStyle(fontSize: 24, color: Colors.red.shade900),
                  ),
                  Slider(
                    value: diastolic.toDouble(),
                    min: 40,
                    max: 120,
                    divisions: 16,
                    onChanged: (value) {
                      setState(() {
                        diastolic = value.toInt();
                      });
                    },
                    activeColor: Colors.red,
                    inactiveColor: Colors.grey[300],
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addRecord,
                    child: Text('Add Record'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Text(
                      'Measured:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

                    ),

                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 240,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("Systolic: ${records[index].systolic} mmHg, Diastolic: ${records[index].diastolic} mmHg at ${records[index].time}"),
                          subtitle: Text('Time: ${records[index].time}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}