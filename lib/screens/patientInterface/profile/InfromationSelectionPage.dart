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
      body:

      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.blue.shade200],
          ),
        ),
        child: ListView(
          children: <Widget>[
            ListTile(

              title: ReusableRow(title:'Account Information' , iconData: Icons.account_circle),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              title:ReusableRow(title:'Medications' , iconData: Icons.medical_services),

              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentPrescriptionScreen(medicationTime: 'morning',)));
              },
            ),
            ListTile(
              title:
            ReusableRow(title:'Reports and Prescriptions' , iconData: Icons.description),

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
