import 'package:design_project_1/models/bloodPressureModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/UrineModel.dart';
import '../../../../services/trackerServices/healthTrackerService.dart';
import 'kidneyTracker.dart';
class UrineTracker extends StatefulWidget {
  @override
  _UrineTrackerState createState() => _UrineTrackerState();
}

class _UrineTrackerState extends State<UrineTracker> {
  List<Urine> records = [];
  double volume = 0.0;
  String color = 'Clear';
  String time = DateFormat('kk:mm').format(DateTime.now());
  void addRecord() async {
    Urine urine = Urine(volume: volume, color: color, time: time);
    await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid)
        .updateUrineData(urine);
    loadUrineData();
  }
  void loadUrineData() async {
    List<Urine> urineData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getUrineData();
    setState(() {
      records = urineData;
    });
  }
  @override
  void initState() {
    super.initState();
    loadUrineData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Urine Tracker'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KidneyTracker() ));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 800,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white70, Colors.blue.shade100],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text(
                        'Enter Urine Volume: ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            volume = double.parse(value);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Urine Volume (in mililiters)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Enter Urine Color: ',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonFormField(
                        value: color,
                        onChanged: (value) {
                          setState(() {
                            color = value.toString();
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            child: Text('Clear'),
                            value: 'Clear',
                          ),
                          DropdownMenuItem(
                            child: Text('Straw Yellow'),
                            value: 'Straw Yellow',
                          ),
                          DropdownMenuItem(
                            child: Text('Brown'),
                            value: 'Brown',
                          ),
                          DropdownMenuItem(
                            child: Text('Red'),
                            value: 'Red',
                          ),

                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter Urine Color',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
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
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text(
                          'Records:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

                        ),

                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                'Volume: ${records[index].volume} ml',
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                'Color: ${records[index].color}',
                                style: TextStyle(fontSize: 16),
                              ),
                              trailing: Text(
                                '${records[index].time}',
                                style: TextStyle(fontSize: 16),
                              ),
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
      ),
    );
  }
}