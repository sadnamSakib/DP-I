import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/BookAppointment/Slots.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../models/AppointmentModel.dart';

class BookAppointment{
  Future<void> bookAppointment(doctorID, String patientID, String slotID,
      String healthIssue, DateTime selectedDate, String day)
  async {
    print(doctorID);
    print(patientID);
    print(slotID);


    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final DocumentSnapshot patientSnapshot = await users.doc(patientID).get();
    final patientData = patientSnapshot.data() as Map<String, dynamic>;


    CollectionReference slots = FirebaseFirestore.instance.collection('Schedule').doc(doctorID).
    collection('Days').doc(day).collection('Slots')
    ;
    final DocumentSnapshot slotSnapshot = await slots.doc(slotID).get();
    final slotData = slotSnapshot.data() as Map<String, dynamic>;


    Appointment newAppointment = Appointment(
      patientId: patientID,
      patientName: patientData['name'],
      isPaid: false,
      issue: healthIssue,
      doctorId: doctorID,
      date: formattedDate,
      startTime: slotData['Start Time'],
      endTime: slotData['End Time'],
      sessionType: slotData['Session Type'],
      slotID: slotID,
    );


    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    CollectionReference appointments = _firestore.collection('Appointments');
    try{
      await appointments.add(newAppointment.toMap());
print('Appointtment');


      String numofpatients = slotData['Number of Patients'].toString();
      int numberOfPatients = int.parse(numofpatients) ;

      numberOfPatients--;
      print(numofpatients);

      DocumentReference slotReference = FirebaseFirestore.instance.collection('Schedule').doc(doctorID)
          .collection('Days').doc(day).collection('Slots').doc(slotID);

      try{
        print(slotReference);
        await slotReference.update({'Number of Patients': numberOfPatients.toString()});

      }catch(e)
    {
      print(e);
    }

      print(numberOfPatients); // Print the updated value


    }
    catch(e)

    {
      print(e);
    }
  }
}