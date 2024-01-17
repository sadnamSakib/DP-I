import 'package:design_project_1/models/PrescriptionModel.dart';
import 'package:design_project_1/screens/patientInterface/medications/previousMedicines.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/medicineServices/medicines.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class CurrentPrescriptionScreen extends StatefulWidget {
  final String medicationTime;
  const CurrentPrescriptionScreen({super.key, required this.medicationTime});

  @override
  State<CurrentPrescriptionScreen> createState() => _CurrentPrescriptionScreenState();
}

class _CurrentPrescriptionScreenState extends State<CurrentPrescriptionScreen> {
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
   List<PrescriptionModel> prescriptions= [];
   late int initialTabIndex;
  @override
  void initState() {
    super.initState();
    loadPrescription(currentUserID).then((value) => setState(() {
      prescriptions = value;
    }));
    if(widget.medicationTime == 'morning'){
      initialTabIndex = 0;
    }
    else if(widget.medicationTime == 'noon'){
      initialTabIndex = 1;
    }
    else if(widget.medicationTime == 'night'){
      initialTabIndex = 2;
    }
    else{
      initialTabIndex = 0;
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
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
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  PreviousMedicineScreen(currentUserID : currentUserID)));
              }, icon: Icon(Icons.history_rounded)
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [Colors.white70, Colors.blue.shade100],
            ),
          ),
          child: FutureBuilder<List<PrescriptionModel>>(
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
      ),
    );
  }
  Widget buildPrescriptionListView(String time) {
    int medicineCount = 0;
    for(var prescription in prescriptions){
      for(var medicine in prescription.prescribedMedicines){
        if(medicine.intakeTime[time] > 0){
          medicineCount++;
        }
      }
    }
    if(medicineCount == 0){
      return Center(child: Text('No medicines for $time '));
    }
    return ListView.builder(
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        final morningMedicines = prescription.prescribedMedicines.where((medicine) => medicine.intakeTime[time] > 0).toList();
        return Column(
          children: morningMedicines.map((prescribedMedicine) {
            final lastDate = DateTime.parse(prescription.date).add(Duration(days: prescribedMedicine.days));
            var remainingDays = 0;
            if(DateTime.now().isAfter(lastDate)){
              remainingDays = 0;
            }
            else{
              remainingDays = lastDate.difference(DateTime.now()).inDays;

            }
            print(remainingDays);
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
              return Container();
            }
          }).toList(),
        );
      },
    );
  }
}


