import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/schedule/dayBasedSchedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/diseaseViewModel.dart';


class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<String> availableDays  = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String>selectedDays = [];
  @override
  void initState() {
    super.initState();
  }


  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: ListView(
            children: <Widget>[
              for (String d in availableDays)
                ListTile(
                  title: Text(d,
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  onTap: () {
                    setState(()  {
                          availableDays.remove(d);
                          selectedDays.add(d);
                    });
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Schedule'),

      ),
      body: selectedDays.isEmpty
          ? Center(
        child: Text(
          'Add day of week to your schedule',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: selectedDays.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              width: 100,
              child: GestureDetector(
                onLongPress: () {
                  // Show delete option
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete day?'),
                        content: Text('Are you sure you want to delete?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              setState(() {
                                availableDays.add(selectedDays[index]);
                                selectedDays.removeAt(index);
                              });
                              Navigator.of(context).pop();

                            },
                            child: Text('Delete'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DayBasedScheduleScreen()),
                  );
                },
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDays[index],
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50, // Adjust the height as needed
                          width: 50, // Adjust the width as needed
                          child: Icon(Icons.calendar_today),
                        ),
                      ],
                    ),
                  ),
                ),

              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        onPressed: () {
          _openModal(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
