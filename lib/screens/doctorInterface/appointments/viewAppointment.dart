import 'package:design_project_1/screens/doctorInterface/appointments/viewPatientDetails.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/models/AppointmentModel.dart';

class ViewAppointmentScreen extends StatefulWidget {
  const ViewAppointmentScreen({Key? key}) : super(key: key);

  @override
  _ViewAppointmentScreenState createState() => _ViewAppointmentScreenState();
}

class _ViewAppointmentScreenState extends State<ViewAppointmentScreen> {
  // Simulated list of appointments. Replace this with your actual appointment data.
  final List<Appointment> appointments = [
    Appointment(
      patientId: 'YmYYfIC919OAlJ9zV9eYhnyQ1Pt2',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Appointments'),
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return ListTile(
            title: Text(appointment.patientName),
            subtitle:

                Text('Issue: ${appointment.issue}'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetailScreen(appointment: appointment)));
            },


            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                appointment.isPaid
                    ? Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right : 8.0),
                      child: Text('Paid', style: TextStyle(color: Colors.green)),
                    ),

                    Icon(Icons.check_circle, color: Colors.green),

                  ],
                )
                    : Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right:8.0),
                      child: Text('Not Paid', style: TextStyle(color: Colors.red)),
                    ),
                    Icon(Icons.cancel, color: Colors.red),

                  ],
                ),
              ],
            ),



            onLongPress: () {
              // Implement cancellation logic here
              _showCancellationDialog(appointment);
            },
          );

        },
      ),
    );
  }

  void _showCancellationDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String cancellationReason = '';

        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to cancel this appointment?'),
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
                _cancelAppointment(appointment);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(Appointment appointment) {
    // Implement cancellation logic, e.g., remove the appointment from the list
    setState(() {
      appointments.remove(appointment);
    });
  }
}


