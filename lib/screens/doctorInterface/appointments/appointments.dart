import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/viewAppointment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../schedule/dayBasedSchedule.dart';
import 'AppointmentClass.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}


class _AppointmentScreenState extends State<AppointmentScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

List<Appointments> appointments=[];



  List<ScheduleItem> dayItems = [];
  // List<ScheduleDay> schedule = [];

  void fetchSchedule(DateTime selectedDay) async {
    print('hhhhhhhhhhhhhhhhhhhhhhhh');
    String searchForDay = DateFormat('EEEE').format(selectedDay);

    print(searchForDay);
    dayItems.clear();
    final scheduleCollection = FirebaseFirestore.instance.collection(
        'Schedule');
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final scheduleQuery = scheduleCollection.doc(userUID);
    final dayScheduleQuery = await scheduleQuery.collection('Days').doc(
        searchForDay).collection('Slots').get();


    for (final slots in dayScheduleQuery.docs) {
      print('looooooooooooooopppppppppppppppppppp');
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
  Future<List<Appointments>> fetchAppointments(selectedDay) async {
    String searchForDate = DateFormat('yyyy-MM-dd').format(selectedDay);

    final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');
    final QuerySnapshot<Object?> querySnapshot = await appointmentsCollection
        .where('doctorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
        .where('date', isEqualTo: searchForDate)
        .get();

    final appointments = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Appointments(
        id: doc.id,
        patientId: data['patientId'],
        patientName: data['patientName'],
        doctorId: data['doctorId'],
        date: data['date'],
        startTime: data['startTime'],
        endTime: data['endTime'],
        sessionType: data['sessionType'],
          isPaid : data['isPaid'],
         issue : data['issue'],
        slotID: data['slotID'],


      );
    }).toList();

    return appointments;
  }

  void getAndStoreAppointments(selectedDay) async {
    final fetchedAppointments = await fetchAppointments(selectedDay);
    setState(() {
      appointments = fetchedAppointments;
    });
  }


  @override
  void initState() {
    super.initState();
    _setWeekRange(DateTime.now());
    fetchSchedule(DateTime.now());
  }

  void _setWeekRange(DateTime selectedDate) {
    _firstDay = DateTime(2000); // Change this to your desired start date
    _lastDay = DateTime(2101); // Change this to your desired end date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: Column(
        children: [
        TableCalendar(
        calendarFormat: CalendarFormat.week,
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 6)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            fetchSchedule(selectedDay);
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          // Add background color property here
          outsideDaysVisible: false, // Optional: hide the days outside the range
        ),
      ),
          Expanded(
            child: _buildAppointmentsForDate(_selectedDay ?? DateTime.now()),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsForDate(DateTime date) {


    void _cancelAppointment(ScheduleItem schedule, String cancellationReason) {

//       final scheduleCollection = FirebaseFirestore.instance.collection(
//           'Schedule');
//       final userUID = FirebaseAuth.instance.currentUser?.uid;
//       final scheduleQuery = scheduleCollection.doc(userUID);
//       final dayScheduleQuery = await scheduleQuery.collection(searchForDay).doc().collection('Slots').get();
//
//
//         final appointmentsCollection = FirebaseFirestore.instance.collection('Schedules').doc();
//         final appointmentReference = appointmentsCollection.doc(schedule.ID);
//
//         final deletedAppointmentsCollection = FirebaseFirestore.instance.collection('DeletedAppointment');
//
//         deletedAppointmentsCollection
//             .add({
//           'appointmentId': appointment.id,
//           'cancellationReason': cancellationReason,
//         })
//             .then((documentReference) {
//
//         })
//             .catchError((error) {
//
//           print("Error creating deleted appointment document: $error");
//         });
//
//         appointmentReference.delete().then((value) {
//
//           Fluttertoast.showToast(
//             msg: 'Appointment deleted',
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.white,
//             textColor: Colors.blue,
//           );
//
//         }).catchError((error) {
//
//           print("Error deleting appointment: $error");
//         });
// initState();
    }

    void _showCancellationDialog(BuildContext context, ScheduleItem scheduleItem) {
      String cancellationReason = '';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Cancel Session'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to cancel this session?'),
                TextField(
                  decoration: InputDecoration(labelText: 'Reason for cancellation'),
                  onChanged: (value) {
                    cancellationReason = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _cancelAppointment(scheduleItem, cancellationReason);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Confirm'),
              ),
            ],
          );
        },
      );
    }



    return ListView(
      children: dayItems
          .map((dayItem) => GestureDetector(
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen(appointment)));
        },
        onLongPress: () {
          _showCancellationDialog(context, dayItem);
        },
            child: Card(
        margin: EdgeInsets.all(8),
        child: ListTile(
            title: Text(
              'Start Time: ${dayItem.startTime}',
              style: TextStyle(fontSize: 16), // Adjust the font size as needed
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Time: ${dayItem.endTime}',
                  style: TextStyle(fontSize: 16), // Adjust the font size as needed
                ),
                Row(
                  children: [
                    Text(
                      'Type: ${dayItem.sessionType == 'Online' ? 'Online' : 'Offline'}',
                      style: TextStyle(fontSize: 16), // Adjust the font size as needed
                    ),
                    SizedBox(width: 8),
                    Icon(
                      dayItem.sessionType == 'Online'
                          ? Icons.circle
                          : Icons.circle,
                      color: dayItem.sessionType == 'Online'
                          ? Colors.blue
                          : Colors.red,
                      size: 16, // Adjust the icon size as needed
                    ),
                  ],
                ),
              ],
            ),
        )

      ),
          ))
          .toList(),
    );


  }





}

