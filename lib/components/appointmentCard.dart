import 'package:flutter/material.dart';

import '../models/AppointmentModel.dart';
import '../screens/patientInterface/viewAppointment/viewAppointmentDetails.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => ViewAppointmentDetailsPage(appointment: appointment),
        ),
      );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Doctor: ${appointment.doctorId}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Time: ${appointment.startTime} - ${appointment.endTime}',
              )
            ],
          ),
        ),
      ),
    );
  }
}
