import 'package:design_project_1/screens/authentication/doctorDetailsPage.dart';
import 'package:design_project_1/screens/authentication/patientDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/profileServices/database.dart';

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
      await DatabaseService(uid: user?.uid).setUserRole(role);
      if(role=='doctor'){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DoctorDetailsPage()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  PatientDetailsPage()));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Role Selection'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RoleCard(
                role: 'Doctor',
                imagePath: 'assets/images/doctor.png',
                onPressed: () => _selectRole('doctor'),
              ),
              SizedBox(height: 40),
              RoleCard(
                role: 'Patient',
                imagePath: 'assets/images/patient.png',
                onPressed: () => _selectRole('patient'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String role;
  final String imagePath;
  final VoidCallback onPressed;

  RoleCard({required this.role, required this.imagePath, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 6.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            Container(
              height: 250,
              width: 350,
              child: Transform(

                transform: Matrix4.identity()..rotateZ(0.0),
                alignment: FractionalOffset.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Continue as $role',
                style: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),


              ),
            ),
          ],
        ),
      ),
    );
  }
}
