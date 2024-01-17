

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/BookAppointment/doctorFinderPage.dart';
import 'package:design_project_1/screens/patientInterface/home/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/AppointmentModel.dart';
import '../screens/patientInterface/viewAppointment/appointmentList.dart';
import '../screens/patientInterface/viewAppointment/viewAppointmentDetails.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String docName;
  final String appointmentID;
  final String weekDay;


  AppointmentCard({required this.appointment,
  required this.docName,
  required this.appointmentID, required this.weekDay});


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
        onLongPress: () {
        _showDeleteAppointmentConfirmationDialog(context,appointmentID,weekDay);

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
                  color: appointment.sessionType == 'Online' ? Colors.blue : Colors.red,
                ),
              )

            ],
          ),
        ),
      ),
    );
  }


  Future<void> _showDeleteAppointmentConfirmationDialog(
      BuildContext context, String appointmentID, String weekDay) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Appointment'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this appointment?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                cancelAppointment(appointmentID, weekDay);
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> cancelAppointment(String appointmentID,String weekDay) async {
    try {
      DocumentSnapshot appointmentSnapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .doc(appointmentID)
          .get();

      if (appointmentSnapshot.exists) {
        String doctorId = appointmentSnapshot['doctorId'] as String;
        String slotID = appointmentSnapshot['slotID'] as String;
        print('Doctor ID: $doctorId');

       await updateSlot(slotID,weekDay,doctorId);

        await FirebaseFirestore.instance
            .collection('Appointments')
            .doc(appointmentID)
            .delete();

        print('Appointment Deleted');
        Fluttertoast.showToast(
          msg: 'Appointment Deleted',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.white,
          textColor: Colors.blue,
        );

      } else {
        print('Appointment with ID $appointmentID not found.');
      }
    } catch (error) {

      print('Error fetching appointment info: $error');
    }
  }

  Future<void> updateSlot(String slotID, String weekDay,String doctorId) async {

    final scheduleCollection = FirebaseFirestore.instance.collection(
        'Schedule');
    final scheduleQuery = scheduleCollection.doc(doctorId);
    final dayScheduleQuery = await scheduleQuery.collection('Days').doc(
        weekDay).collection('Slots').doc(slotID).get();

    if (dayScheduleQuery.exists) {
      Map<String, dynamic> scheduleData = dayScheduleQuery.data() as Map<String, dynamic>;

      int currentNumberOfPatients = int.parse(scheduleData['Number of Patients'] ?? '0');
      int newNumberOfPatients = currentNumberOfPatients + 1;

      await scheduleQuery.collection('Days').doc(weekDay).collection('Slots').doc(slotID).update({
        'Number of Patients': newNumberOfPatients.toString(),

      });

      print('SLOT UPDATED');

    } else {
      print('Document not found for the given slotID');
    }
  }

}
