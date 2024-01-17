import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/viewAppointment/appointmentList.dart';
import 'package:design_project_1/services/paymentServices/Payment.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../../../components/virtualConsultation/call.dart';
import '../../../models/AppointmentModel.dart';
import 'ShareDocuments.dart';

class ViewAppointmentDetailsPage extends StatefulWidget {
  final Appointment appointment;
  final String ID;

  ViewAppointmentDetailsPage({super.key, required this.appointment,
  required this.ID});


  @override
  State<ViewAppointmentDetailsPage> createState() => _ViewAppointmentDetailsPageState();
}

class _ViewAppointmentDetailsPageState extends State<ViewAppointmentDetailsPage> {

  late  Map<String, dynamic>? doctorData ;
  late  Map<String, dynamic>? patientData ;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final  userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
  Future username = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) => value.data()!['name']);
  String userName = '';

  String generateCallID() {
    String callID = '';
    callID = widget.appointment.doctorId;
    return callID;
  }

  Future<void> fetchDocInfo()
  async {
    doctorData = null;
    final doctorReference = FirebaseFirestore.instance.collection('doctors').doc(widget.appointment.doctorId);
    final doctorSnapshot = await doctorReference.get();

    if (doctorSnapshot.exists) {
      setState(() {

       doctorData = doctorSnapshot.data() as Map<String, dynamic>;
      });

    }
  }


  Future<void> fetchPatientInfo()
  async {
    patientData = null;
    final patientReference = FirebaseFirestore.instance.collection('patients').
    doc(FirebaseAuth.instance.currentUser?.uid ?? ''
    );
    final patientSnapshot = await patientReference.get();

    if (patientSnapshot.exists) {
      setState(() {

        patientData = patientSnapshot.data() as Map<String, dynamic>;
      });

    }
  }


  @override
  void initState()
  {
    fetchDocInfo();
    fetchPatientInfo();
    setState(() {
      username.then((value) => userName = value.toString());
    });

  }

   Map<String, dynamic>? paymentIntent;

  Appointment get appointment => widget.appointment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),
        child: Padding(
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
                title: Text('Health Issue: ${appointment.issue.isNotEmpty ? appointment.issue :  'No issue specified'}'),

              ),
              ListTile(
                leading: Icon(Icons.health_and_safety),
                title: Text('Pre existing medical conditions: ${patientData?['preExistingConditions']?.join(', ')}'),

              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Doctor Name: ${doctorData?['name']}'),
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
              onPressed: () async {

                if('${doctorData?['Fee']}' == '')
                {
                  Fluttertoast.showToast(
                    msg: "Payment can not done now. Please try again later.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentListPage()),
                  );
                }
                else{
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SSLCommerze(appointmentID: widget.ID, appointment: widget.appointment, fee: doctorData?['Fee'],)),
                  );
                }


              },
              child: Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                fixedSize: Size(100, 30),
              ),
            )
                : null,
          ),
          SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.shade900),
                      fixedSize: MaterialStateProperty.all<Size>(Size(150, 40)),
                    ),
                    onPressed: () {
                      _showBottomSheet(context);
                    },
                    child: Text('View Options'),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }




  void _showBottomSheet(BuildContext context){
    showModalBottomSheet(
      context : context,
      builder: (context) => Container(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SharedDocuments(doctorID: widget.appointment.doctorId)));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medical_services,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8.0),
                  Text('Your shared Reports and Prescriptions')
                ],
              ),
            ),

            appointment.sessionType == 'Online' ?  TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),

              onPressed: () {

                Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage(callID: generateCallID() , userID: userId , userName: userName)));

                },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.call,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8.0),
                  Text('Join Session'),
                ],
              ),
            ) :

            ListTile(
               leading: Icon(Icons.location_on),
                title: Text('Chamber Address : ${doctorData?['chamberAddress']}',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
                ),
          ],
        ),
      ),
    );
  }


}
