import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/database.dart';

class RoleSelectionPage extends StatefulWidget {
  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String role = '';

  void _selectRole(String role) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Set custom claim based on the selected role
      await DatabaseService(uid: user?.uid).setUserRole(role);
      Navigator.pushReplacementNamed(context, '/home'); // Replace with your home page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Role Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _selectRole('doctor'),
              child: Text('I am a Doctor'),
            ),
            ElevatedButton(
              onPressed: () => _selectRole('patient'),
              child: Text('I am a Patientt'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                // Add your navigation logic here
              },
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
