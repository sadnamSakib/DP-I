import 'package:design_project_1/screens/doctorInterface/appointments/viewAppointment.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:design_project_1/models/AppointmentModel.dart';

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

  @override
  void initState() {
    super.initState();
    _setWeekRange(DateTime.now());
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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


    // Simulated list of appointments. Replace this with your actual data.
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
          sessionType: 'Online'
      ),
      // Add more appointments here
    ];

    void _cancelAppointment(Appointment appointment, String cancellationReason) {
      setState(() {
        appointments.remove(appointment);
      });
    }

    void _showCancellationDialog(BuildContext context, Appointment appointment) {
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
                  // Implement your cancellation logic here, using `appointment` and `cancellationReason`
                  _cancelAppointment(appointment, cancellationReason);
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
      children: appointments
          .map((appointment) => GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAppointmentScreen()));
        },
        onLongPress: () {
          _showCancellationDialog(context, appointment);
        },
            child: Card(
        margin: EdgeInsets.all(8),
        child: ListTile(
            title: Text(
              'Start Time: ${appointment.startTime}',
              style: TextStyle(fontSize: 16), // Adjust the font size as needed
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End Time: ${appointment.endTime}',
                  style: TextStyle(fontSize: 16), // Adjust the font size as needed
                ),
                Row(
                  children: [
                    Text(
                      'Type: ${appointment.sessionType == 'Online' ? 'Online' : 'Offline'}',
                      style: TextStyle(fontSize: 16), // Adjust the font size as needed
                    ),
                    SizedBox(width: 8),
                    Icon(
                      appointment.sessionType == 'Online'
                          ? Icons.circle
                          : Icons.circle,
                      color: appointment.sessionType == 'Online'
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



  String _formatTime(DateTime time) {
    String period = time.hour >= 12 ? 'PM' : 'AM';
    int hour = time.hour > 12 ? time.hour - 12 : time.hour;
    int minute = time.minute;
    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $period';
  }


}

