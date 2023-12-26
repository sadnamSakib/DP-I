import 'package:csv/csv.dart';
import 'Medicine.dart';
import 'dart:io';
import 'package:flutter/services.dart';


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

