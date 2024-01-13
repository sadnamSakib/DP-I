import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/schedule/dayBasedSchedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/models/diseaseViewModel.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<String> availableDays  = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String>selectedDays = [];
  List<String>bookedDays = [];

  bool hasSchedule=false;
  List<ScheduleDay> schedule = []; // Declare schedule here
  List<ScheduleDay> fetchedSchedule =[];


  @override
  void initState() {
    super.initState();
    checkForSchedules();



  }





  Future<List<ScheduleDay>> fetchSchedule() async {
    selectedDays.clear();
    final scheduleCollection = FirebaseFirestore.instance.collection('Schedule');
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final scheduleQuery = await scheduleCollection.doc(userUID);

    // Initialize the list to hold the schedules
    List<ScheduleDay> schedule = [];

    // Define the days you want to access
    final daysToAccess = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (final day in daysToAccess) {
      final dayScheduleQuery = await scheduleQuery.collection('Days').doc(day).collection('Slots').get();
      if(dayScheduleQuery.size > 0 )
        {
          selectedDays.add(day);
        }
      List<ScheduleItem> dayItems = [];

      for (final slotDoc in dayScheduleQuery.docs) {
        final startTime = slotDoc['Start Time'];
        final endTime = slotDoc['End Time'];
        final sessionType = slotDoc['Session Type'];
        final numberOfPatients = slotDoc['Number of Patients'];
          print(startTime);
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
      print(selectedDays);
      setState(() {
        for(final days in selectedDays)
        {
          print(days);
          availableDays.remove(days);
        }
      });
      // setState(() async {
      //   fetchedSchedule = await fetchSchedule(); // Update the class-level list
      //
      // });
    }
    }


  Future<void> addCancelledAppointment(String appointmentID, String slotID) async {
    final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');

    try {
      print('INNNN TRYYYYYYYYYYYYY');
      final appointmentDocument = await appointmentsCollection.doc(appointmentID).get();
      if (appointmentDocument.exists) {
        print('EXISTSTTTTTTTTTTTTTTTTTTTTT');
        final Map<String, dynamic>? appointmentData = appointmentDocument.data() as Map<String, dynamic>?;

        if (appointmentData != null) {
          final String date = appointmentData['date'] as String; // Replace 'date' with the actual field name

          final collection = FirebaseFirestore.instance.collection('DeletedAppointment');

          print('colectttttttttttttttttttionnnnnnnnnnnnn');
          collection.add({
            'appointmentID': appointmentID ?? '',
            'slotID': slotID ?? '',
            'cancellationReason':  '',
            'patientID': appointmentData['patientId'] ?? '',
            'appointmentDate': date ?? '',
            'issue': appointmentData['issue'] ?? '',
          });

          // Now you have retrieved the 'date' field from the appointment document
          print('Date of the appointment: $date');
        } else {
          print('Appointment data is null for ID: $appointmentID');
        }
      } else {
        print('Appointment document does not exist for ID: $appointmentID');
      }
    } catch (e) {
      print('Error retrieving appointment data: $e');
    }
  }



  Future<void> deleteAppointmentsForSlot(String slotID) async {
    try {
      // Reference to the Appointments collection
      final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');

      // Define a query to find the appointments with matching slotID
      final query = appointmentsCollection.where('slotID', isEqualTo: slotID);

      // Use the query to retrieve matching documents
      final querySnapshot = await query.get();

      for (final doc in querySnapshot.docs) {

        final appointmentID = doc.id;
        print(appointmentID);
        print('appppppp paiseeeeeeeeeeeeeeee');

        await addCancelledAppointment(appointmentID,slotID);
        // Reference to the document to delete
        final docReference = appointmentsCollection.doc(doc.id);

        // Delete the document
        await docReference.delete();

        // Log the deletion
        print('Appointment with ID ${doc.id} has been deleted for the slot with ID: $slotID');
      }

      print('All matching appointments for slot with ID: $slotID have been deleted successfully.');
    } catch (e) {
      print('Error deleting documents: $e');
    }
  }




  Future<void> delete(String Day) async {
    try {
      final scheduleCollection = FirebaseFirestore.instance.collection('Schedule');
      final userUID = FirebaseAuth.instance.currentUser?.uid;
      final scheduleQuery = scheduleCollection.doc(userUID);
      final slotsCollection = scheduleQuery.collection('Days').doc(Day).collection('Slots');

      final slotsQuery = await slotsCollection.get();

      for (final slotDoc in slotsQuery.docs) {
        final slotID = slotDoc.id;
        print(slotID);
        print('SLOT IDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD');


        deleteAppointmentsForSlot(slotID);

        await slotDoc.reference.delete();
      }

      setState(() {
        checkForSchedules();
        // fetchSchedule();
      });

      print('All documents in Slots collection for $Day deleted successfully.');
    } catch (e) {
      print('Error deleting documents: $e');
    }
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
    // if (hasSchedule) {
    //
    //
    // else{
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade900,
        title: Text('Schedule'),

      ),
      body: selectedDays.isEmpty
          ? Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.white70, Colors.pink.shade100])),
            child: Center(
        child: Text(
            'Add day of week to your schedule',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
          )
          :
      Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white70, Colors.pink.shade100])),
        child: ListView.builder(
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
                                  delete(selectedDays[index]);
                                  Fluttertoast.showToast(
                                    msg: 'Schedule and associated appointments deleted',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.blue,
                                  );
                                  // availableDays.add(selectedDays[index]);
                                  // selectedDays.removeAt(index);
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
                            DayBasedScheduleScreen(selectedDay: selectedDays[index]),
                      ),
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
                              selectedDays[index], // Use bookedDays here
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
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade900,
        onPressed: () {
          _openModal(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  // }
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

