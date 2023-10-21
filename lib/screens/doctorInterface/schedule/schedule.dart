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
  bool hasSchedule=false;
  List<ScheduleDay> schedule = []; // Declare schedule here
  List<ScheduleDay> fetchedSchedule =[];
  @override
  void initState() {
    super.initState();
    checkForSchedules();
  }





  Future<List<ScheduleDay>> fetchSchedule() async {
    final scheduleCollection = FirebaseFirestore.instance.collection('Schedule');
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final scheduleQuery = await scheduleCollection.doc(userUID);

    // Initialize the list to hold the schedules
    List<ScheduleDay> schedule = [];

    // Define the days you want to access
    final daysToAccess = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (final day in daysToAccess) {
      final dayScheduleQuery = await scheduleQuery.collection('Days').doc(day).collection('Slots').get();

      List<ScheduleItem> dayItems = [];

      for (final slotDoc in dayScheduleQuery.docs) {
        final startTime = slotDoc['Start Time'];
        final endTime = slotDoc['End Time'];
        final sessionType = slotDoc['Session Type'];
        final numberOfPatients = slotDoc['Number of Patients'];

        setState(() {
          dayItems.add(ScheduleItem(
            startTime: startTime,
            endTime: endTime,
            sessionType: sessionType,
            numberOfPatients: numberOfPatients,
          ));
        });

      }

      // Add the schedule for this day to the list
      // setState(() {

      schedule.add(ScheduleDay(day: day, items: dayItems));
      // });
    }

    return schedule;
  }


  Future<void> checkForSchedules() async {
    final userUID = FirebaseAuth.instance.currentUser?.uid;

      final scheduleDocument = await FirebaseFirestore.instance
          .collection('Schedule') // Outer collection
          .doc(userUID) // Document within the outer collection
          ; // Subcollection
      print(scheduleDocument.id);
      print(userUID);

      if ((scheduleDocument.id) == userUID) {

        setState(() {
          hasSchedule = true;
        });
      }


    if (hasSchedule) {

      fetchedSchedule = await fetchSchedule();
      // setState(() async {
      //   fetchedSchedule = await fetchSchedule(); // Update the class-level list
      //
      // });
    }
      for (final slots in fetchedSchedule) {

        for (final item in slots.items) {
          print('Start Time: ${item.startTime}');
          print('End Time: ${item.endTime}');
          print('Session Type: ${item.sessionType}');
        }
      }
    }


  void _openModal(BuildContext context) {
    List<String> daysInSchedule = [];
    for (var day in fetchedSchedule) {
      daysInSchedule.add(day.day);
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(

          height: 200,
          child: ListView(
            children: <Widget>[
              for (String d in availableDays)
                if (hasSchedule && !daysInSchedule.contains(d)) // Check if day is in schedule
                  ListTile(
                    title: Text(d, style: TextStyle(fontSize: 20)),
                    onTap: () {
                      setState(() {
                        availableDays.remove(d);
                        selectedDays.add(d);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
              if (!hasSchedule)
                for (String d in availableDays)
                  ListTile(
                    title: Text(d, style: TextStyle(fontSize: 20)),
                    onTap: () {
                      setState(() {
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
    if (hasSchedule) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Your Schedules'),
        ),
        body: ListView.builder(
          itemCount: fetchedSchedule.length,
          itemBuilder: (context, index) {
            final day = fetchedSchedule[index];

            return Card(
              elevation: 5.0,
              margin: EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50],
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('Day: ${day.day}'),
                    ),
                    for (final item in day.items)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.lightBlue[100],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text('Start Time: ${item.startTime}'),
                            ),
                            ListTile(
                              title: Text('End Time: ${item.endTime}'),
                            ),
                            ListTile(
                              title: Text('Session Type: ${item.sessionType}'),
                            ),
                            ListTile(
                              title: Text('Number of Patients: ${item.numberOfPatients}'),
                            ),
                          ],
                        ),
                      ),
                  ],
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


    else{
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
                      MaterialPageRoute(
                        builder: (context) =>
                            DayBasedScheduleScreen(
                                selectedDay: selectedDays[index]),
                      )
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
    // }
  }
}


class ScheduleItem {
  final String startTime;
  final String endTime;
  final String sessionType;
  final String numberOfPatients; // Add the 'numberOfPatients' field

  ScheduleItem({
    required this.startTime,
    required this.endTime,
    required this.sessionType,
    required this.numberOfPatients,
  });
}

class ScheduleDay {
  final String day;
  final List<ScheduleItem> items;

  ScheduleDay({
    required this.day,
    required this.items,
  });
}

