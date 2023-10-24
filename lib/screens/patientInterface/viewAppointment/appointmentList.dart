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
                fetchAppointments(selectedDay);
                });

              },
            ),
        Expanded(
          child: ListView(
            children: <Widget>[
              for (int i = 0; i < appointments.length; i++)
                FutureBuilder<String?>(
                  future: fetchDoctorName(appointments[i].doctorId),
                  builder: (context, snapshot) {
                    String doctorName = snapshot.data ?? '';
                    // Get the appointment at the current index
                    Appointment appointment = appointments[i];
                    // Get the corresponding appointment ID
                    String appointmentID = appointmentIds[i];
                    print(appointmentID);
                    print('Apppppppppppppppppppp');

                    return AppointmentCard(appointment: appointment, docName: doctorName,
                        appointmentID :appointmentID);

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
      setState(() {
    appointmentIds.clear();

       });
    if (selectedDay == null) {
      return;
    }
    appointments.clear();
    print('dayyyyyyyyyyyyyyyyyyyyyyyyyy');
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

      // Convert the query results into a list of Appointment objects
      setState(() {
        appointments = querySnapshot.docs.map((doc) {
          appointmentIds.add(doc.id);
          final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          if (data != null) {
            print('List');
            return Appointment(
              patientId: data['patientId']?? '',
              patientName: data['patientName'] ?? '',
              isPaid: data['isPaid'] ?? '',
              issue: data['issue'] ?? '',
              doctorId: data['doctorId'] ?? '',
              date: data['date'] ?? '',
              startTime: data['startTime'] ?? '',
              endTime: data['endTime'] ?? '',
              sessionType: data['sessionType'] ?? '',
              slotID: data['slotID'] ?? '',
            );
          } else {
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
              slotID: ''
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
