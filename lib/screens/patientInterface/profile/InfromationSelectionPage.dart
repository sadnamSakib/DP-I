import 'package:design_project_1/screens/patientInterface/Storage/Upload.dart';
import 'package:design_project_1/screens/patientInterface/medications/currentPrescription.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/screens/patientInterface/profile/profile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InformationSelectionScreen extends StatefulWidget {
  const InformationSelectionScreen({super.key});

  @override
  State<InformationSelectionScreen> createState() => _InformationSelectionScreenState();
}

class _InformationSelectionScreenState extends State<InformationSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
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
    child: ListView(
    children: <Widget>[
    ListTile(
    contentPadding: EdgeInsets.all(10.0),
    tileColor: Colors.blue.shade100,
    leading: Icon(Icons.account_circle,
    size: 40.0),
    title: Text('Account Information',
    style: TextStyle(
    fontSize: 18.0,
    ),),
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
    },
    ),
    ListTile(
    contentPadding: EdgeInsets.all(10.0),
    tileColor: Colors.grey.shade200,
    leading: Icon(Icons.medical_services,
    size: 40.0),
    title: Text('Medications',
    style: TextStyle(
    fontSize: 18.0,
    ),),
    onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentPrescriptionScreen(medicationTime: 'morning',)));
    },
    ),
    ListTile(
    contentPadding: EdgeInsets.all(10.0),
    tileColor: Colors.blue.shade50,
    leading: Icon(Icons.description,
    size: 40.0),
    title: Text('Reports and Prescriptions',
    style: TextStyle(
    fontSize: 18.0,
    ),),
    onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadFile()));
    },
    ),


        ],
      ),
    ),
    );
  }
}
