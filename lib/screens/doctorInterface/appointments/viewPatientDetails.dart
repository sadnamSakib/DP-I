import 'package:flutter/material.dart';
import 'package:design_project_1/models/AppointmentModel.dart';
import 'healthTrackerSummaryScreen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(widget.appointment.patientName),
            subtitle: Text('Gender: Male'),
          ),
          ListTile(
            title: Text('Issue'),
            subtitle: Text(widget.appointment.issue),
          ),
          ListTile(
            title: Text('Previous Issues'),
            subtitle: Text("Hypertension,Asthma"),
          ),
          ListTile(
            title: Text('Phone Number'),
            subtitle: Text('01791239573'),
          ),
          ListTile(
            title: Text('Session Type'),
            subtitle: Text(widget.appointment.sessionType),
          ),
          ListTile(
            title: Text('Paid'),
            subtitle: Text(widget.appointment.isPaid ? 'Yes' : 'No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HealthTrackersScreen(patientId: widget.appointment.patientId)));
            },
            child: Text('View Health Tracker Information'),
          ),

          ElevatedButton(
            onPressed: () {
              // Implement the logic to call the patient into a session.
              // You can use the phone number from widget.appointment.phoneNumber.
            },
            child: Text('Call into Session'),
          ),
        ],
      ),
    );
  }
}