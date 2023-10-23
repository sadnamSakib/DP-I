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
                    if (_startTime == null)
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
                    if (_endTime == null)
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
        ),
        body: Column(
          children: [
            Expanded(
              child:
              ListView(
                children: <Widget>[
                  for (final slots in dayItems)
                    Material(
                      elevation: 6,
                      child: Card(
                        color: Colors.blue.shade50,
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
                                'Start Time: ${slots.startTime}',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                'End Time: ${slots.endTime}',
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
            // Expanded(
              // child: ListView(
              //   children: <Widget>[
              //     for (final session in _sessions)
              //       Card(
              //           color: Colors.grey.shade200,
              //           margin: EdgeInsets.all(8),
              //           child: ListTile(
              //             title: Text('Start Time: ${session.startTime.format(context)}',
              //                 style : TextStyle(fontSize: 20)),
              //             subtitle: Row(
              //               children: [
              //                 Text('End Time: ${session.endTime.format(context)}',
              //                     style : TextStyle(fontSize: 20)),
              //                 SizedBox(width: 8), // Add some spacing
              //                 Text(session.sessionType, style: TextStyle(color: Colors.grey, fontSize: 20),),
              //                 Text(session.NumberOfPatients, style: TextStyle(color: Colors.grey, fontSize: 20),),
              //
              //                 SizedBox(width: 10),
              //                 Container(
              //                   width: 20,
              //                   height: 20,
              //                   decoration: BoxDecoration(
              //                     shape: BoxShape.circle,
              //                     color: session.sessionType == "Online" ? Colors.blue : Colors.red,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           )
              //
              //       ),
              //   ],
              // ),
            // ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
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

// class ScheduleDay {
//   final String day;
//   final List<ScheduleItem> items;
//
//   ScheduleDay({
//     required this.day,
//     required this.items,
//   });
// }

