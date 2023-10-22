import 'package:flutter/material.dart';
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
  final List<Appointment> appointments = [
    Appointment(
        patientId: '1',
        patientName: 'John Doe',
        issue: 'Fever',
        date : '22-10-2023',
        startTime : '10:00',
        endTime : '10:30',
        isPaid: true,
        doctorId: '1',
        sessionType: 'Online'
    ),
    Appointment(
        patientId: '2',
        patientName: 'Jane Doe',
        issue: 'Headache',
        date : '22-10-2023',
        startTime : '10:00',
        endTime : '10:30',
        isPaid: false,
        doctorId: '1',
        sessionType: 'Offline'
    ),
    // Add more appointments here
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Appointments'),
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
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                for (var appointment in appointments)
                  AppointmentCard(appointment: appointment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
