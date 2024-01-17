import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/MedicineModel.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:design_project_1/models/PrescriptionModel.dart';
import 'package:design_project_1/models/PrescribedMedicineModel.dart';
import 'package:text2pdf/text2pdf.dart';

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

void generatePrescriptionPDF(PrescriptionModel prescription) async {
  final prescriptionText = await generatePrescriptionText(prescription);
  final pdf = await Text2Pdf.generatePdf(prescriptionText);

}

generatePrescriptionText(PrescriptionModel prescription) async {
  final doctorName = await FirebaseFirestore.instance.collection('users').doc(prescription.doctorId).get().then((value) => value.data()!['name']);

  final patientName = await FirebaseFirestore.instance.collection('users').doc(prescription.patientId).get().then((value) => value.data()!['name']);
  final date = DateTime.parse(prescription.date).toLocal().toString().split(' ')[0];
  final medicines = prescription.prescribedMedicines;

  String prescriptionText = 'Doctor Name: $doctorName\n'
      'Patient Name: $patientName\n'
      'Date: $date\n\n';

  for (final prescribedMedicine in medicines) {
    final medicineDetails = prescribedMedicine.medicineDetails;
    final intakeTime = prescribedMedicine.intakeTime;
    final days = prescribedMedicine.days;
    final String isBeforeMeal = prescribedMedicine.isBeforeMeal ? 'before meal' : 'after meal';

    prescriptionText += 'Medicine: ${medicineDetails.brandName} ${medicineDetails.strength}\n'
        'Intake Time: ${intakeTime['morning']}+${intakeTime['noon']}+${intakeTime['night']}\n'
        'Days: $days\n'
        'Take $isBeforeMeal\n\n';
  }

  return prescriptionText;
}



Future<List<PrescriptionModel>> loadPrescription(String patientId) async {
  List<PrescriptionModel> prescriptions = [];
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('prescriptions')
        .where('patientId', isEqualTo: patientId)
        .get();

    for (final doc in querySnapshot.docs) {
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        final prescription = PrescriptionModel(
          patientId: data['patientId'],
          doctorId: data['doctorId'],
          date: data['date'],
          prescribedMedicines:[],
        );
        for (final prescribedMedicine in data['prescribedMedicines']) {
          final medicineDetails = prescribedMedicine['medicineDetails'];
          final intakeTime = prescribedMedicine['intakeTime'];
          final prescribedMedicineModel = PrescribeMedicineModel(
            medicineDetails: Medicine(
              brandName: medicineDetails['brandName'],
              dosageForm: medicineDetails['dosageForm'],
              generic: medicineDetails['generic'],
              strength: medicineDetails['strength'],
              manufacturer: medicineDetails['manufacturer'],
            ),
            intakeTime: {
              'morning': intakeTime['morning'],
              'noon': intakeTime['noon'],
              'night': intakeTime['night'],
            },
            days: prescribedMedicine['days'],
            isBeforeMeal: prescribedMedicine['isBeforeMeal'],
          );
          prescription.prescribedMedicines.add(prescribedMedicineModel);
        }

        prescriptions.add(prescription);
      }
    }
  } catch (e) {
    print('Error fetching prescriptions: $e');
  }

  return prescriptions;
}

Stream<List<Medicine>> loadCurrentlyRunningMedicines(String patientId) {
  final StreamController<List<Medicine>> controller = StreamController<List<Medicine>>();

  FirebaseFirestore.instance
      .collection('prescriptions')
      .where('patientId', isEqualTo: patientId)
      .snapshots()
      .listen((QuerySnapshot querySnapshot) {
    List<Medicine> medicines = [];
    for (final doc in querySnapshot.docs) {
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        for (final prescribedMedicine in data['prescribedMedicines']) {
          final medicineDetails = prescribedMedicine['medicineDetails'];
          final medicine = Medicine(
            brandName: medicineDetails['brandName'],
            dosageForm: medicineDetails['dosageForm'],
            generic: medicineDetails['generic'],
            strength: medicineDetails['strength'],
            manufacturer: medicineDetails['manufacturer'],
          );
          medicines.add(medicine);
        }
      }
    }
    controller.add(medicines);
  });

  return controller.stream;
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

Future<String> getDoctorName(String doctorId) async {
  String doctorName = '';
  await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get().then((value) => doctorName = value.data()!['name']);
  return doctorName;
}


