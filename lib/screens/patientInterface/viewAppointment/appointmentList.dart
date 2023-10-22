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
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Appointment> appointments = [];

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
            colors: [Colors.white70, Colors.blue.shade200],
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
                });
                fetchAppointments(selectedDay);

              },
            ),
          Expanded(
            child: ListView(
              children: <Widget>[
                for (var appointment in appointments)
                  FutureBuilder<String?>(
                    future: fetchDoctorName(appointment.doctorId),
                    builder: (context, snapshot) {
                        String doctorName = snapshot.data ?? '';
                        return AppointmentCard(appointment: appointment, docName: doctorName);

                    },
                  ),
              ],
            ),
          ),


          ],
        ),
      ),
    );
  }

  void fetchAppointments(DateTime selectedDay) async{
    appointments.clear();
    // print('dayyyyyyyyyyyyyyyyyyyyyyyyyy');
    String Searchfordate = DateFormat('yyyy-MM-dd').format(selectedDay);
    CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('Appointments');

    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {

      final QuerySnapshot<Object?> querySnapshot = await appointmentsCollection
          .where('patientId', isEqualTo: currentUserId)
          .where('date', isEqualTo: Searchfordate)
          .get();

      // Convert the query results into a list of Appointment objects
      setState(() {
        appointments = querySnapshot.docs.map((doc) {
          final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            print('List');
            return Appointment(
              patientId: data['patientId'],
              patientName: data['patientName'] ?? '', // Provide a default value if it's null
              isPaid: data['isPaid'] ?? '', // Provide a default value if it's null
              issue: data['issue'] ?? '', // Provide a default value if it's null
              doctorId: data['doctorId'] ?? '', // Provide a default value if it's null
              date: data['date'] ?? '', // Provide a default value if it's null
              startTime: data['startTime'] ?? '', // Provide a default value if it's null
              endTime: data['endTime'] ?? '', // Provide a default value if it's null
              sessionType: data['sessionType'] ?? '', // Provide a default value if it's null
            );
          } else {
            // Handle the case where data is null (optional)
            return Appointment(
              patientId: '',
              patientName: '',
              isPaid: false,
              issue: '',
              doctorId: '',
              date: '',
              startTime: '',
              endTime: '',
              sessionType: '',
            );
          }
        }).toList();
      });


      // return appointments;
    } catch (e) {
      print('Error fetching appointments: $e');
      // return [];
    }
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
}
