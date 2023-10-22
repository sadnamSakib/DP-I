import 'package:flutter/material.dart';

import '../../../models/AppointmentModel.dart';
class ViewAppointmentDetailsPage extends StatefulWidget {
  final Appointment appointment;

  ViewAppointmentDetailsPage({super.key, required this.appointment});


  @override
  State<ViewAppointmentDetailsPage> createState() => _ViewAppointmentDetailsPageState();
}

class _ViewAppointmentDetailsPageState extends State<ViewAppointmentDetailsPage> {

  Appointment get appointment => widget.appointment;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Patient Name: ${appointment.patientName}'),
            ),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text('Health Issue: ${appointment.issue}'),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Doctor ID: ${appointment.doctorId}'),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text('Estimated Time: ${appointment.startTime} - ${appointment.endTime}'),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Date: ${appointment.date}'),
            ),
        ListTile(
          leading: Icon(Icons.payment),
          title: Text('Payment Status: ${appointment.isPaid ? 'Paid' : 'Not Paid'}'),
          trailing: !appointment.isPaid
              ? ElevatedButton(
            onPressed: () {
              // Add logic to handle payment
            },
            child: Text('Pay Now'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue.shade900  ,
            ),
          )
              : null,
        ),
        SizedBox(height: 16),
            if (appointment.sessionType == 'Online')
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add logic to join online session
                  },
                  child: Text('Join Session'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900  ,
                  )
                ),
              ),
            if (appointment.sessionType == 'Offline')
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Chamber Address: '),
              ),

          ],
        ),
      ),
    );
  }
}
