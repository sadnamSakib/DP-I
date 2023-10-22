import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/AppointmentModel.dart';
import '../screens/patientInterface/viewAppointment/viewAppointmentDetails.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String docName;

  AppointmentCard({required this.appointment,
  required this.docName});



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
                'Doctor: ${docName}',
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
