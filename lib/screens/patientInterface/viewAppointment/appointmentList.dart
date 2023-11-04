import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../components/appointmentCard.dart';
import '../../../models/AppointmentModel.dart';
class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  List<String> appointmentIds = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<Appointment> appointments = [];
  int len = 0;

  @override
  void initState()
  {
    fetchAppointments(selectedDate);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Appointments'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // colors: [Colors.white70, Colors.blue.shade200],
            colors: [Colors.white70, Colors.blue.shade100],
          ),
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
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  setState(() {

                fetchAppointments(selectedDay);
                  });
                });

              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: appointments.isEmpty ? 1 : appointments.length,
                itemBuilder: (context, index) {
                  if (appointments.isEmpty) {
                    return Center(
                      child: Text('No appointments available for the selected day.'),
                    );
                  } else {
                    final doctorId = appointments[index].doctorId;
                    final appointmentId = appointmentIds[index];
                    return FutureBuilder<String?>(
                      future: fetchDoctorName(doctorId),
                      builder: (context, snapshot) {
                        String doctorName = snapshot.data ?? '';
                        return AppointmentCard(appointment: appointments[index], docName: doctorName, appointmentID: appointmentId);
                      },
                    );
                  }
                },
              )
              ,

            )
            ,



          ],
        ),
      ),
    );
  }

  void fetchAppointments(DateTime selectedDay) async {
    setState(() {
      appointmentIds.clear();
    appointments.clear();
    });

    if (selectedDay == null) {
      return;
    }

    print(selectedDay);
    String Searchfordate = DateFormat('yyyy-MM-dd').format(selectedDay);
    print(Searchfordate);
    CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');

    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      final QuerySnapshot<Object?> querySnapshot = await appointmentsCollection
          .where('patientId', isEqualTo: currentUserId)
          .where('date', isEqualTo: Searchfordate)
          .get();

      for (var doc in querySnapshot.docs) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          print('List');

          String StartTime = data['startTime'];
          String EndTime = data['endTime'];
          String date = data['date'];

          if (!await missedAppointment(StartTime, EndTime, doc.id, date,Searchfordate)) {
            // Only add the appointment if missedAppointment returns false
            setState(() {
            appointmentIds.add(doc.id);

            appointments.add(Appointment(
              patientId: data['patientId'] ?? '',
              patientName: data['patientName'] ?? '',
              isPaid: data['isPaid'] ?? '',
              issue: data['issue'] ?? '',
              doctorId: data['doctorId'] ?? '',
              date: data['date'] ?? '',
              startTime: data['startTime'] ?? '',
              endTime: data['endTime'] ?? '',
              sessionType: data['sessionType'] ?? '',
              slotID: data['slotID'] ?? '',
            ));


            });

            print(appointments.toString());
            print(data['sessionType']);
          }
        }
        setState(() {
          len = appointments.length;
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }


  Future<bool> missedAppointment(String startTime, String endTime, String docID,
      String documentDate, String selectedDate)
  async {
    String StartTime = timeformatting(startTime);
    String EndTime = timeformatting(endTime);


    DateTime currentDate = DateTime.now();
    String formattedCurrentDate = "${currentDate.year}-${currentDate.month
        .toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(
        2, '0')}";

// Compare the dates
    int comparisonResult = formattedCurrentDate.compareTo(documentDate);

    DateTime now = DateTime.now();
    String currentTime = DateFormat('h:mm a').format(DateTime.now());
    DateTime parsedDateTime = DateTime.parse(selectedDate);
    DateTime currentDateTime = DateTime.now();


    print(currentTime);
    print('CURRENT  TIMEEEEEEEEEEEEE');

    DateTime currentTimeFormat = DateFormat('h:mm a').parse(
        currentTime); // Parse current time
    DateTime endTimeFormat = DateFormat('h:mm a').parse(
        EndTime); // Parse end time
    if (parsedDateTime == currentDateTime) {

      if (currentTimeFormat.isBefore(endTimeFormat)) {
      // Current time is before end time
      // Do something
    } else if (currentTimeFormat.isAfter(endTimeFormat)) {
      final appointmentRef = FirebaseFirestore.instance.collection(
          'Appointments').doc(docID);


      final DocumentSnapshot appointmentSnapshot = await appointmentRef.get();

      final Map<String, dynamic> appointmentdata = appointmentSnapshot
          .data() as Map<String, dynamic>;

      // You can now access the fields in the appointment document
      CollectionReference missedAppointmentsCollection = FirebaseFirestore
          .instance.collection('MissedAppointments');

      // Add the appointment data to the "MissedAppointments" collection
      await missedAppointmentsCollection.add({
        'patientId': appointmentdata['patientId'] ?? '',
        'patientName': appointmentdata['patientName'] ?? '',
        'issue': appointmentdata['issue'] ?? '',
        'doctorId': appointmentdata['doctorId'] ?? '',
        'date': appointmentdata['date'] ?? '',
        'startTime': appointmentdata['startTime'] ?? '',
        'endTime': appointmentdata['endTime'] ?? '',
        'sessionType': appointmentdata['sessionType'] ?? '',
        'slotID': appointmentdata['slotID'] ?? '',
      });


      await appointmentRef.delete();


      print("Appointment withhhhhhhhhh ID $docID to beeeeeeeeeeeeee  deleted.");
      return true;
      // Current time is after end time
      // Do something else
    } else {
      // Current time is equal to end time
      // Do something else
    }
  }

    return false;
  }
  Future<String?> fetchDoctorName(String doctorId) async {
    final doctorReference = FirebaseFirestore.instance.collection('doctors').doc(doctorId);
    final doctorSnapshot = await doctorReference.get();

    if (doctorSnapshot.exists) {
      final doctorData = doctorSnapshot.data() as Map<String, dynamic>;
      return doctorData['name'];
    }

    return null;
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
}
