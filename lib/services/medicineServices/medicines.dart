import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/MedicineModel.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:design_project_1/models/PrescriptionModel.dart';
import 'package:design_project_1/models/PrescribedMedicineModel.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;



Future<List<Medicine>> loadMedicines() async {
  final csvString = await rootBundle.loadString('assets/medicineList.csv');
  final csvList = CsvToListConverter().convert(csvString);

  // Skip the first row (header row) and map the rest to Medicine objects
  final medicines = csvList.skip(1).map((row) {
    return Medicine(
      brandName: row[0],
      dosageForm: row[1],
      generic: row[2],
      strength: row[3],
      manufacturer: row[4],
    );
  }).toList();

  return medicines;
}

Future<void> addPrescribedMedicine(String patientId, PrescribeMedicineModel prescribedMedicine) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  String doctorId = auth.currentUser!.uid;
  String prescriptionId = doctorId + patientId;

  DocumentReference prescriptionRef = firestore.collection('prescriptions').doc(prescriptionId);

  DocumentSnapshot prescriptionSnapshot = await prescriptionRef.get();

  if (prescriptionSnapshot.exists) {
    // If the prescription already exists, add the new prescribed medicine to the list
    await prescriptionRef.update({
      'prescribedMedicines': FieldValue.arrayUnion([prescribedMedicine.toMap()])
    });
  } else {
    // If the prescription does not exist, create a new one
    final prescription = PrescriptionModel(
      patientId: patientId,
      doctorId: doctorId,
      date: DateTime.now().toString(),
      prescribedMedicines: [prescribedMedicine],
    );

    await prescriptionRef.set(prescription.toMap());
  }
}


