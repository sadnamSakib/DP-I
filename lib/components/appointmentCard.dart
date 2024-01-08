import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/AppointmentModel.dart';
import '../screens/patientInterface/viewAppointment/viewAppointmentDetails.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String docName;
  final String appointmentID;

  AppointmentCard({required this.appointment,
  required this.docName,
  required this.appointmentID});

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



  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: () { Navigator.push(context,

        MaterialPageRoute(
          builder: (context) => ViewAppointmentDetailsPage(appointment: appointment, ID :appointmentID),
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
                'Time: ${timeformatting(appointment.startTime)} - ${timeformatting(appointment.endTime)}',
              ),
              Text(
                appointment.sessionType == 'Online' ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: appointment.sessionType == 'Online' ? Colors.blue : Colors.red, // Change the color based on the session type
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
