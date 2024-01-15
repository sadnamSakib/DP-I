import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/appointments/viewAppointment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../services/cancellationServices/cancellationNotification.dart';
import '../../../services/notificationServices/notification_services.dart';
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
  bool _isLoading = true;

List<Appointments> appointments=[];
  NotificationServices notificationServices = NotificationServices();

  final currentDayOfWeek = DateTime.now().weekday; // Ensure DateTime.now() is not null
  final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];




  List<ScheduleItem> dayItems = [];
  @override
  void initState() {
  print(currentDayOfWeek);
    super.initState();
    _setWeekRange(DateTime.now());
    fetchSchedule(daysOfWeek[currentDayOfWeek - 1]);
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
  // List<ScheduleDay> schedule = [];

  void fetchSchedule(String selectedDay) async {
    String searchForDay = selectedDay;

    print(searchForDay);
    setState(() {

    dayItems.clear();
    });
    final scheduleCollection = FirebaseFirestore.instance.collection(
        'Schedule');
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    final scheduleQuery = scheduleCollection.doc(userUID);
    final dayScheduleQuery = await scheduleQuery.collection('Days').doc(
        searchForDay).collection('Slots').get();


    for (final slots in dayScheduleQuery.docs) {
      final id = slots.id;
      final startTime = slots['Start Time'];
      final endTime = slots['End Time'];
      final sessionType = slots['Session Type'];
      final numberOfPatients = slots['Number of Patients'];
      print(id);
      print(startTime);
      setState(() {
        dayItems.add(ScheduleItem(
          ID : id,
          startTime: startTime,
          endTime: endTime,
          sessionType: sessionType,
          numberOfPatients: numberOfPatients,
        ));
      });

    }
    setState(() {
      _isLoading = false;
    });
  }




  void _setWeekRange(DateTime selectedDate) {
    _firstDay = DateTime(2000);
    _lastDay = DateTime(2101);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade900,
        title: Text('Appointments'),
      ),
      body:
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter, // 10% of the width, so there are ten blinds.
            colors: [Colors.white70, Colors.pink.shade50], // whitish to gray// repeats the gradient over the canvas
          )
        ),
        child: Column(
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
              selectedDay = selectedDay;
              fetchSchedule(DateFormat('EEEE').format(selectedDay));
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
          ),
        ),
            Expanded(
              child: _isLoading
                  ? Center(
                child: SpinKitCircle(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ): dayItems.isEmpty? Text("No slots") : _buildAppointmentsForDate(_selectedDay ?? DateTime.now()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsForDate(DateTime date) {


    Future<void> addCanceledAppointment(String appointmentID, String slotID, String cancellationReason) async

    {

      final collection = FirebaseFirestore.instance.collection('DeletedAppointment');

      try {
        final appointmentReference = FirebaseFirestore.instance.collection('Appointments').doc(appointmentID);
        final appointmentSnapshot = await appointmentReference.get();
        final appointmentData = appointmentSnapshot.data();

        if (appointmentData != null) {

          final patientID = appointmentData['patientID'] as String?;
          final appointmentDate = appointmentData['date'] as String?;
          final issue = appointmentData['issue'] as String?;

          // Store these extracted fields in the "DeletedAppointment" collection
          await collection.add({
            'appointmentID': appointmentID ?? '',
            'slotID': slotID,
            'cancellationReason': cancellationReason ?? '',
            'patientID': patientID ?? '',
            'appointmentDate': appointmentDate ?? '',
            'issue': issue ?? '',
            'doctorID' : appointmentData['doctorId']
          });

          notifyPatient(appointmentData['patientId'], appointmentData['doctorId'],
              appointmentData['date'],appointmentData['startTime']
          );
          print('Canceled appointment added to DeletedAppointment collection.');
        } else {
          print('Document data is null, cannot add canceled appointment.');
        }
      } catch (e) {
        print('Error adding canceled appointment: $e');
      }
    }

    Future<void> deleteSlot(String id) async
    {

      String searchForDay = DateFormat('EEEE').format(_selectedDay!);

      print(searchForDay);

      try {

        final scheduleCollection = FirebaseFirestore.instance.collection('Schedule');
        final userUID = FirebaseAuth.instance.currentUser?.uid;
        final scheduleQuery = scheduleCollection.doc(userUID);
        final slotReference = scheduleQuery
            .collection('Days')
            .doc(searchForDay)
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


    void _cancelAppointment(ScheduleItem schedule, String cancellationReason) {

      final appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');

      // Define a query to find the appointments with matching slotID
      final query = appointmentsCollection.where('slotID', isEqualTo: schedule.ID);

      // Use the query to retrieve matching documents
      query.get().then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((doc) async {
            // Reference to the document to delete
            final docReference = appointmentsCollection.doc(doc.id);

            await addCanceledAppointment(doc.id, schedule.ID, cancellationReason);

            // Delete the document
            docReference.delete().then((_) {
              // The appointment has been deleted
              print('Appointment with ID ${doc.id} has been deleted for the schedule with ID: ${schedule.ID}');
            }).catchError((error) {
              print('Error deleting appointment: $error');
            });
          });
        } else {
          print('No matching appointments found.');
        }
      });

      deleteSlot(schedule.ID);
      fetchSchedule(DateFormat('EEEE').format(_selectedDay!));
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
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _cancelAppointment(scheduleItem, cancellationReason);
                  Navigator.of(context).pop();
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen(slotID : dayItem.ID)));
        },
        onLongPress: () {
          _showCancellationDialog(context, dayItem);
        },
            child: Card(
        margin: EdgeInsets.all(8),
        child: ListTile(
            title: Text(
              'Start Time: ${timeformatting(dayItem.startTime)}',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Time: ${timeformatting(dayItem.endTime)}',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Text(
                      'Type: ${dayItem.sessionType == 'Online' ? 'Online' : 'Offline'}',
                      style: TextStyle(fontSize: 16),
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

  void notifyPatient(String patientId, String doctorId, String date, String startTime) {

    cancellationOfNotification().notifyPatient(patientId,doctorId,date,startTime);

  }




}

