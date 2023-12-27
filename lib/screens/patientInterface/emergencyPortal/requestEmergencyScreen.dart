import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/screens/patientInterface/emergencyPortal/chat.dart';

class RequestEmergencyScreen extends StatefulWidget {
  const RequestEmergencyScreen({super.key});

  @override
  State<RequestEmergencyScreen> createState() => _RequestEmergencyScreenState();
}

class _RequestEmergencyScreenState extends State<RequestEmergencyScreen> {
  final _auth = FirebaseAuth.instance;
  final String receiverID = FirebaseAuth.instance.currentUser!.uid;
  final String receiverEmail = FirebaseAuth.instance.currentUser!.email.toString();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Emergency'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.red.shade800,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          fixedSize: Size(150.0, 100.0),
        ),
        child: Icon(Icons.emergency_outlined,
          size: 50.0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chat(receiverUserEmail: receiverEmail, receiverUserID: receiverID)),
          );
        },
      ),
    )
    );
  }
}