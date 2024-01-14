import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/schedule/SetSchedule.dart';
import 'package:design_project_1/screens/doctorInterface/schedule/schedule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DayBasedScheduleScreen extends StatefulWidget {
  final String selectedDay;

  const DayBasedScheduleScreen({Key? key, required this.selectedDay})
      : super(key: key);
  @override
  State<DayBasedScheduleScreen> createState() => _DayBasedScheduleScreenState();
}


class _DayBasedScheduleScreenState extends State<DayBasedScheduleScreen> {

  List<ScheduleItem> dayItems = [];
  // List<ScheduleDay> schedule = [];

  void fetchSchedule() async {
    dayItems.clear();
    final scheduleCollection = FirebaseFirestore.instance.collection(
        'Schedule');
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final scheduleQuery = scheduleCollection.doc(userUID);
    final dayScheduleQuery = await scheduleQuery.collection('Days').doc(
        widget.selectedDay).collection('Slots').get();

    // Initialize the list to hold the schedules

    for (final slots in dayScheduleQuery.docs) {
      final id = slots.id;
      final startTime = slots['Start Time'];
      final endTime = slots['End Time'];
      final sessionType = slots['Session Type'];
      final numberOfPatients = slots['Number of Patients'];
      print(startTime);
      setState(() {
        dayItems.add(ScheduleItem(
          ID : id,
          startTime: startTime,
          endTime: endTime,
          sessionType: sessionType,
          numberOfPatients: numberOfPatients,
        ));
        // schedule.add(ScheduleDay(day: widget.selectedDay, items: dayItems));
      });

    }
      // return schedule;
  }
  String timeformatting(String Time) {


    List<String> timeParts = Time.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    String period = hours >= 12 ? 'PM' : 'AM';
    if (hours > 12) {
      hours -= 12;
    } else if (hours == 0) {
      hours = 12;
    }

    String hour = hours.toString().padLeft(2,'0');
    String minute = minutes.toString().padLeft(2,'0');

    String formattedTime = '$hour:$minute $period';

    print('HOURRRRR');
    print("Formatted Time: $formattedTime");

    return formattedTime;

  }

@override
void initState() {
    fetchSchedule();
    // print(schedule);
}
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _sessionType;
  String? _NumberOfPatients;

  List<Session> _sessions = [];

  void _showAddSessionDialog() async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Session"),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_startTime == null || _endTime == null)
                      ElevatedButton(
                        onPressed: () async {
                          startTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (startTime != null) {
                            setState(() {
                              _startTime = startTime;
                            });
                          }
                        },
                        child: Text("Select Start Time"),
                      ),
                    if (_endTime == null || _startTime == null)
                      ElevatedButton(
                        onPressed: () async {
                          endTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (endTime != null) {
                            setState(() {
                              _endTime = endTime;
                            });
                          }
                        },
                        child: Text("Select End Time"),
                      ),
                    if (_startTime != null)
                      ListTile(
                        title: Text("Start Time: ${_startTime!.format(context)}"),
                      ),
                    if (_endTime != null)
                      ListTile(
                        title: Text("End Time: ${_endTime!.format(context)}"),
                      ),
                    DropdownButtonFormField<String>(
                      value: _sessionType,
                      items: ["Online", "Offline"]
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sessionType = value;
                        });
                      },
                      decoration: InputDecoration(labelText: "Session Type"),
                    ),


                    TextFormField(
                      keyboardType: TextInputType.text, // Input type as number
                      decoration: InputDecoration(labelText: "Number of Patients"),
                      onChanged: (value) {
                        _NumberOfPatients = value;
                      },
                    ),



                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {

                    if (_formKey.currentState!.validate()) {

                      if (_startTime == null || _endTime == null || _sessionType == null || _NumberOfPatients == null) {
                        Fluttertoast.showToast(
                          msg: 'Failed to add slot. Please fill all the fields',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.red,
                        );
                        Navigator.of(context).pop();
                      }
                      else{
                      _addSession();
                      final SelectedDay = widget.selectedDay;
                      final setScheduleInstance = SetSchedule(
                        selectedDay: SelectedDay,
                        startTime: _startTime != null
                            ? '${_startTime!.hour}:${_startTime!.minute}'
                            : '', // Format the time if available
                        endTime: _endTime != null
                            ? '${_endTime!.hour}:${_endTime!.minute}'
                            : '', // Format the time if available
                        sessionType: _sessionType ?? '',
                         numberofPatients: _NumberOfPatients ?? '',
                      );
                      setScheduleInstance.AddSchedule();

                      fetchSchedule();
                      setState(() {
                        _startTime = null;
                        _endTime = null;
                        _sessionType = null;
                        _NumberOfPatients = null;
                      });
                      // Create a new ScheduleItem


                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                        msg: 'Schedule Added',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.red,
                      );

                      }
                      // initState();
                    }

                  },
                  child: Text("Add Session"),
                ),
              ],
            );
          },
        );
      },
    );
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


  Future<void> deleteSlot(String id) async {
    try {
      final scheduleCollection = FirebaseFirestore.instance.collection('Schedule');
      final userUID = FirebaseAuth.instance.currentUser?.uid;
      final scheduleQuery = scheduleCollection.doc(userUID);
      final slotReference = scheduleQuery
          .collection('Days')
          .doc(widget.selectedDay)
          .collection('Slots')
          .doc(id);

     await deleteAppointmentsForSlot(id);
      await slotReference.delete();
      setState(() {
        dayItems.removeWhere((item) => item.ID == id);
      });

      print('Document with ID $id deleted successfully.');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  void _addSession() {
    if (_startTime != null && _endTime != null && _NumberOfPatients != null && _sessionType != null) {
      final session = Session(
        startTime: _startTime!,
        endTime: _endTime!,
        sessionType: _sessionType!,
        NumberOfPatients: _NumberOfPatients!,
      );

      setState(() {
        _sessions.add(session);
      });
    }
  }

  void _showUpdateSessionDialog(String id) async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final scheduleCollection = FirebaseFirestore.instance.collection('Schedule');
            final userUID = FirebaseAuth.instance.currentUser?.uid;
            final scheduleQuery = scheduleCollection.doc(userUID);
            final slotReference = scheduleQuery
                .collection('Days')
                .doc(widget.selectedDay)
                .collection('Slots')
                .doc(id);

            return AlertDialog(
              title: Text("Update Session"), // Change the title to "Update Session"
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_startTime == null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal.shade800,
                          onPrimary: Colors.white,
                        ),
                        onPressed: () async {
                          startTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (startTime != null) {
                            setState(() {
                              _startTime = startTime;
                            });
                          }
                        },
                        child: Text("Select Start Time"),
                      ),
                    if (_endTime == null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal.shade800,
                          onPrimary: Colors.white,
                        ),
                        onPressed: () async {
                          endTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (endTime != null) {
                            setState(() {
                              _endTime = endTime;
                            });
                          }
                        },
                        child: Text("Select End Time"),
                      ),
                    if (_startTime != null)
                      ListTile(
                        title: Text("Start Time: ${_startTime!.format(context)}"),
                      ),
                    if (_endTime != null)
                      ListTile(
                        title: Text("End Time: ${_endTime!.format(context)}"),
                      ),
                    DropdownButtonFormField<String>(
                      value: _sessionType,
                      items: ["Online", "Offline"]
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sessionType = value;
                        });
                      },
                      decoration: InputDecoration(labelText: "Session Type"),
                    ),


                    TextFormField(
                      keyboardType: TextInputType.text, // Input type as number
                      decoration: InputDecoration(labelText: "Number of Patients"),
                      onChanged: (value) {
                        _NumberOfPatients = value;
                      },
                    ),



                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal.shade800,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_startTime == null ||
                          _endTime == null ||
                          _sessionType == null ||
                          _NumberOfPatients == null) {
                        Fluttertoast.showToast(
                          msg: 'Failed to update slot. Please fill all the fields',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.red,
                        );
                        Navigator.of(context).pop();
                      } else {
                        _addSession();
                        final SelectedDay = widget.selectedDay;
                        final sTime = _startTime != null
                            ? '${_startTime!.hour}:${_startTime!.minute}'
                            : ''; // Format the time if available
                        final eTime = _endTime != null
                            ? '${_endTime!.hour}:${_endTime!.minute}'
                            : ''; // Format the time if available
                        final sessionType = _sessionType ?? '';
                        final numberOfPatients = _NumberOfPatients ?? '';

                        await slotReference.update({
                          'Start Time': sTime,
                          'End Time': eTime,
                          'Session Type': sessionType,
                          'Number of Patients': numberOfPatients,
                        });

                        fetchSchedule();
                        setState(() {
                          _startTime = null;
                          _endTime = null;
                          _sessionType = null;
                          _NumberOfPatients = null;
                        });

                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: Text("Update Session"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Day-Based Schedule'),
          backgroundColor: Colors.pink.shade900,
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.white70, Colors.pink.shade100])),
          child: Column(
            children: [
              Expanded(
                child:
                ListView(
                  children: <Widget>[
                    for (final slots in dayItems)
                      Material(
                        elevation: 6,
                        child: Card(
                          color: Colors.teal.shade50,
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(
                              'Day: ${widget.selectedDay}',
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.left, // Align title to the left
                            ),
                            isThreeLine: true, // Make ListTile three-line
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Align subtitle to the left
                              children: [
                                Text(
                                  'Start Time: ${timeformatting(slots.startTime)}',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  'End Time: ${timeformatting(slots.endTime)}',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            contentPadding: EdgeInsets.all(16), // Add more padding to the ListTile
                            onTap: () {
                              _showUpdateSessionDialog(slots.ID);
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text('Are you sure you want to delete this slot?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          // User confirmed deletion, call the deleteSlot function
                                          deleteSlot(slots.ID); // Pass the ID of the document to delete
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: Text('Delete'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog without deletion
                                        },
                                        child: Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                )
                  ,
              ),

            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal.shade900,
          onPressed: _showAddSessionDialog,
          child: Icon(Icons.add),
        ),
      );
    }

  }


class Session {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String sessionType;
  final String NumberOfPatients;

  Session({
    required this.startTime,
    required this.endTime,
    required this.sessionType,
    required this.NumberOfPatients,
  });
}



class ScheduleItem {
  final String ID;
  final String startTime;
  final String endTime;
  final String sessionType;
  final String numberOfPatients; // Add the 'numberOfPatients' field

  ScheduleItem({
    required this.ID,
    required this.startTime,
    required this.endTime,
    required this.sessionType,
    required this.numberOfPatients,
  });
}

