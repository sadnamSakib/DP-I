import 'package:design_project_1/models/PrescriptionModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/medicineServices/medicines.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class CurrentPrescriptionScreen extends StatefulWidget {
  const CurrentPrescriptionScreen({super.key});

  @override
  State<CurrentPrescriptionScreen> createState() => _CurrentPrescriptionScreenState();
}

class _CurrentPrescriptionScreenState extends State<CurrentPrescriptionScreen> {
  final currentUserID = FirebaseAuth.instance.currentUser!.uid;
   List<PrescriptionModel> prescriptions= [];
  @override
  void initState() {
    super.initState();
    loadPrescription(currentUserID).then((value) => setState(() {
      prescriptions = value;
    }));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Prescription'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          if(prescriptions.isNotEmpty)
            IconButton(
                onPressed: () {
                  generatePrescriptionPDF(prescriptions[0]);
                },
                icon: Icon(Icons.picture_as_pdf)
            ),
        ],
      ),
      body: FutureBuilder<List<PrescriptionModel>>(
        future: loadPrescription(currentUserID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || prescriptions == null) {
            return Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {

            return (prescriptions.isNotEmpty)
                ? ListView.builder(
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptions[index];
                return Column(
                  children: prescription.prescribedMedicines.map((prescribedMedicine) {
                    final intakeTime = prescribedMedicine.intakeTime;
                    var remainingDays = DateTime.now().difference(DateTime.parse(prescription.date)).inDays;
                    remainingDays += prescribedMedicine.days;
                    if (remainingDays > 0) {
                      return ListTile(
                        title: Text('${prescribedMedicine.medicineDetails.brandName} ${prescribedMedicine.medicineDetails.strength}'),
                        subtitle: Text('${intakeTime['morning']}+${intakeTime['noon']}+${intakeTime['night']} Remaining days: $remainingDays'),
                      );
                    } else {
                      return Container(); // Return an empty container if remainingDays is not greater than 0
                    }
                  }).toList(),
                );
              },
            )
                : Center(child: Text('No prescribed medicines found'));
          }
        },
      ),
    );
  }
}
