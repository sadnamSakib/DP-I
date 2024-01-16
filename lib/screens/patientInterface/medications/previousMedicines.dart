import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:design_project_1/services/medicineServices/medicines.dart';
import '../../../models/PrescriptionModel.dart';
import '../../../services/medicineServices/medicines.dart';

class PreviousMedicineScreen extends StatefulWidget {
  final String currentUserID;
  const PreviousMedicineScreen({super.key, required this.currentUserID});

  @override
  State<PreviousMedicineScreen> createState() => _PreviousMedicineScreenState();
}

class _PreviousMedicineScreenState extends State<PreviousMedicineScreen> {
  List<PrescriptionModel> prescriptions= [];
  @override
  void initState() {
    super.initState();
    loadPrescription(widget.currentUserID).then((value) => setState(() {
      prescriptions = value;
    }));
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Medicines'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: FutureBuilder<List<PrescriptionModel>>(
        future: loadPrescription(widget.currentUserID),
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
          }
          else {

            return (prescriptions.isNotEmpty)
                ? buildPreviousMedicinesList()

                : Center(child: Text('No previous medicines found'));
          }
        },
      ),
    );
  }
  Widget buildPreviousMedicinesList() {
    int countOfPreviousMedicines = 0;
    for(var prescription in prescriptions){
      for(var medicine in prescription.prescribedMedicines){
        final lastDate = DateTime.parse(prescription.date).add(Duration(days: medicine.days));
        var remainingDays = 0;
        if(DateTime.now().isAfter(lastDate)){
          remainingDays = 0;
        }
        else{
          remainingDays = lastDate.difference(DateTime.now()).inDays;
        }
        if(remainingDays == 0) {
          countOfPreviousMedicines++;
        }
      }
    }
    if(countOfPreviousMedicines == 0){
      return Center(child: Text('No previous medicines found'));
    }
    return ListView.builder(
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        final len = prescription.prescribedMedicines.length;
        final previousMedicines = [];
        for(var medicine in prescription.prescribedMedicines){
          final lastDate = DateTime.parse(prescription.date).add(Duration(days: medicine.days));
          var remainingDays = 0;
          if(DateTime.now().isAfter(lastDate)){
            remainingDays = 0;
          }
          else{
            remainingDays = lastDate.difference(DateTime.now()).inDays;
          }
          if(remainingDays == 0) {
            previousMedicines.add(medicine);
          }
        }
        if(previousMedicines.isEmpty){
          return Container();
        }
        return Column(
          children: [
            ListTile(
              title: Text('Prescribed on : '+ DateTime.parse(prescription.date).toLocal().toString().split(' ')[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Colors.red,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: previousMedicines.length,
              itemBuilder: (context, index) {
                final medicine = previousMedicines[index];
                return ListTile(
                  title: Text('${medicine.medicineDetails.brandName} ${medicine.medicineDetails.strength} - ${medicine.days} days'),
                  subtitle: Text('${medicine.intakeTime['morning']} + ${medicine.intakeTime['noon']} + ${medicine.intakeTime['night']}'),
                );

              },
            ),
          ],
        );
      },
    );
  }
}
