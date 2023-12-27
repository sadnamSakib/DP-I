import 'package:flutter/material.dart';
import 'package:design_project_1/screens/doctorInterface/emergencyPortal/chat.dart';

class RequestEmergencyScreen extends StatefulWidget {
  const RequestEmergencyScreen({super.key});

  @override
  State<RequestEmergencyScreen> createState() => _RequestEmergencyScreenState();
}

class _RequestEmergencyScreenState extends State<RequestEmergencyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Request emergency assistance from a doctor'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chat(receiverUserEmail: 'null', receiverUserID: 'null')),
          );
        },
      ),
    );
  }
}