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
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final scheduleCollection = FirebaseFirestore.instance.collection('Schedule');

    final scheduleQuery = await scheduleCollection.doc(userUID).collection('Days').get();

    // schedule.clear();

    for (final dayDoc in scheduleQuery.docs) {
      final dayId = dayDoc.id;
      print(dayId);
      final data = dayDoc.data() as Map<String, dynamic>;

      final startTime = data['Start Time'];
      print(startTime);
      final endTime = data['End Time'];
      print(endTime);

      final sessionType = data['Session Type'];
      print(sessionType);


      setState(() {

      schedule.add(ScheduleDay(
        day: dayId,
        items: [
          ScheduleItem(
            startTime: startTime,
            endTime: endTime,
            sessionType: sessionType,
          ),
        ],
      ));
      });
    }

    return schedule;
  }


  Future<void> checkForSchedules() async {
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final userDocument = await FirebaseFirestore.instance.collection('users')
        .doc(userUID)
        .get();

    if (userDocument.id != null) {
      final scheduleDocument = await FirebaseFirestore.instance
          .collection('Schedule') // Outer collection
          .doc(userUID) // Document within the outer collection
          ; // Subcollection
      print(scheduleDocument.id);

      if ((scheduleDocument.id) == userUID) {
        setState(() {
          hasSchedule = true;
        });
      }

      print(userUID);
    }

    if (hasSchedule) {
      // fetchedSchedule = await fetchSchedule();
      setState(() async {
        fetchedSchedule = await fetchSchedule(); // Update the class-level list

      });
      // print('Fetched Schedule:');
      // for (final day in fetchedSchedule) {
      //   print('Day: ${day.day}');
      //   for (final item in day.items) {
      //     print('Start Time: ${item.startTime}');
      //     print('End Time: ${item.endTime}');
      //     print('Session Type: ${item.sessionType}');
      //   }
      //   print('ggggggggggggggggggggggghasSchedul');
      // }
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
            print(fetchedSchedule.length);
            final day = fetchedSchedule[index];
            print('Day: ${day.day}'); // Debug print

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Day: ${day.day}'),
                  for (final item in day.items)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Time: ${item.startTime}'),
                        Text('End Time: ${item.endTime}'),
                        Text('Session Type: ${item.sessionType}'),
                      ],
                    ),
                ],
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
                      builder: (context) => DayBasedScheduleScreen(selectedDay: selectedDays[index]),
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
  }
}



class ScheduleItem {
  final String startTime;
  final String endTime;
  final String sessionType;

  ScheduleItem({
    required this.startTime,
    required this.endTime,
    required this.sessionType,
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
