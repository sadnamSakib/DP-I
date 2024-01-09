import 'package:design_project_1/screens/patientInterface/Storage/UploadFile.dart';
import 'package:design_project_1/screens/patientInterface/medications/currentPrescription.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/screens/patientInterface/profile/profile.dart';
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
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Account Information'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Medications'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrentPrescriptionScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Reports and Prescriptions'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadFile()));
            },
          ),
        ],
      ),
    );
  }
}
