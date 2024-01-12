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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Morning', icon: Icon(Icons.sunny_snowing)),
              Tab(text: 'Noon', icon: Icon(Icons.sunny)),
              Tab(text: 'Night', icon: Icon(Icons.nightlight_round_outlined)),
            ],
          ),
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
                  ? TabBarView(
                children: [
                  buildPrescriptionListView('morning'),
                  buildPrescriptionListView('noon'),
                  buildPrescriptionListView('night'),
                ],
              )
                  : Center(child: Text('No prescribed medicines found'));
            }
          },
        ),
      ),
    );
  }
  Widget buildPrescriptionListView(String time) {
    return ListView.builder(
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        final morningMedicines = prescription.prescribedMedicines.where((medicine) => medicine.intakeTime[time] > 0).toList();
        return Column(
          children: morningMedicines.map((prescribedMedicine) {
            final lastDate = DateTime.parse(prescription.date).add(Duration(days: prescribedMedicine.days));
            var remainingDays = DateTime.now().difference(lastDate).inDays;
            remainingDays += prescribedMedicine.days;
            if (remainingDays > 0) {
              return Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text('${prescribedMedicine.medicineDetails.brandName} ${prescribedMedicine.medicineDetails.strength}'),
                        ),
                        Expanded(
                          child: Text('Qty: ${prescribedMedicine.intakeTime[time]}', textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text('Remaining: $remainingDays days'),
                        ),
                        Expanded(
                          child: Text(prescribedMedicine.isBeforeMeal ? 'Before Meal' : 'After Meal', textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade400,
                    thickness: 1.0,
                  ),
                  // Add a Divider here
                ],
              );
            } else {
              return Container(); // Return an empty container if remainingDays is not greater than 0
            }
          }).toList(),
        );
      },
    );
  }
}


