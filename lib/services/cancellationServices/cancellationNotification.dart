import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../chatServices/ServerKey.dart';

class cancellationOfNotification {


  Future<String?> fetchPatientTokens(String patientID) async {
    try {
      DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientID)
          .get();

      if (patientSnapshot.exists) {
        String deviceToken = patientSnapshot['deviceToken'];

        print('Device Token for Patient $patientID: $deviceToken');
        return deviceToken;
      } else {
        print('Patient with ID $patientID not found.');
        return '';
      }
    } catch (error) {
      print('Error fetching patient device token: $error');
    }
  }

  Future<String?> fetchDoctorName(String doctorId) async {
    try {
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      if (doctorSnapshot.exists) {
        String doctorName = doctorSnapshot['name'];

        return doctorName;
      } else {
        print('Patient with ID $doctorId not found.');
        return '';
      }
    } catch (error) {
      print('Error fetching patient device token: $error');
    }
  }
  Future<void> notifyPatient(String patientId, String doctorId, String date, String startTime) async {
    print(patientId);
    String? patientToken = await fetchPatientTokens(patientId);
    String? doctorName = await fetchDoctorName(doctorId);


    String notificationBody = 'Your appointment with ${doctorName} on ${date} has been cancelled';
    try{
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': key.toString(),
        },
        body: jsonEncode(

          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': 'Your appointment with ${doctorName} on ${date} has been cancelled',
              'title':'Appointment Canceled' ,
              'type': 'cancelAppointment',
            },
            'notification': <String, dynamic>{
              'body': 'Your appointment with ${doctorName} on ${date} has been cancelled',
              'title': 'Appointment Canceled',
              'android_channel_id': '4',
            },

            'to': patientToken.toString(),
          },
        ),
      );
    }
    catch(e){
      if(kDebugMode) {
        print("error in sending notification");
      }
    }
  }

  }




