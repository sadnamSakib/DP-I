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
  String initialMessage = "";
  final TextEditingController _messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Emergency'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLines: 3,
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: "Emergency Note",
                  hintText: "Include the health issue for better assistance",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red.shade800,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                fixedSize: Size(100.0, 50.0),
              ),
              child: Icon(Icons.emergency_outlined,
                size: 40.0,
              ),
              onPressed: () {
                initialMessage = _messageController.text;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Chat(receiverUserID: receiverID, initialMessage: initialMessage,)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}