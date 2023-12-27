import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:design_project_1/services/medicineServices/medicines.dart';
import 'package:design_project_1/models/MedicineModel.dart';
import 'package:design_project_1/models/PrescribedMedicineModel.dart';


class PrescribeMedicineScreen extends StatefulWidget {
  final patientId;
  const PrescribeMedicineScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<PrescribeMedicineScreen> createState() => _PrescribeMedicineScreenState();
}

class _PrescribeMedicineScreenState extends State<PrescribeMedicineScreen> {
  String query = '';
  List<Medicine> searchResults = [];
  List<Medicine> medicines = [];

  @override
  void initState() {
    super.initState();
    loadMedicines().then((value) {
      setState(() {
        medicines = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // This avoids the overflow error when keyboard appears
      appBar: AppBar(
        title: Text('Search Medicine'),
      ),
      body:SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // ... other widgets
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    query = value;
                    if(query == ''){
                      searchResults = [];
                      return;
                    }
                    searchResults = medicines.where((element) => element.brandName.toLowerCase().startsWith(query.toLowerCase()) || element.generic.toLowerCase().startsWith(query.toLowerCase())).toList();
                  });
                },
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search for medicine",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true, // Add this line
              itemCount: min(searchResults.length, 5),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(searchResults[index].brandName + ' ' + searchResults[index].strength),
                  subtitle: Text(searchResults[index].generic),
                  onTap : (){
                    _showPrescribeMedicineModalBottomSheet(context, searchResults[index] , widget.patientId);
                  }
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showPrescribeMedicineModalBottomSheet(BuildContext context, Medicine medicine , String patientId) {
  bool morning = false;
  bool noon = false;
  bool night = false;
  bool isBeforeMeal = true;
  int days = 0;
  String specialNote = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      bool morning = false;
      bool noon = false;
      bool night = false;
      bool isBeforeMeal = true;
      int days = 0;
      String specialNote = '';

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CheckboxListTile(
                    title: Text('Morning'),
                    value: morning,
                    onChanged: (bool? value) {
                      setState(() {
                        morning = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Noon'),
                    value: noon,
                    onChanged: (bool? value) {
                      setState(() {
                        noon = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Night'),
                    value: night,
                    onChanged: (bool? value) {
                      setState(() {
                        night = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text('Before Meal'),
                    value: true,
                    groupValue: isBeforeMeal,
                    onChanged: (bool? value) {
                      setState(() {
                        isBeforeMeal = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: Text('After Meal'),
                    value: false,
                    groupValue: isBeforeMeal,
                    onChanged: (bool? value) {
                      setState(() {
                        isBeforeMeal = value!;
                      });
                    },
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      days = int.parse(value);
                    },
                    decoration: InputDecoration(
                      labelText: "Days",
                      hintText: "Enter number of days",
                    ),
                  ),
                  TextField(
                    onChanged: (value) {
                      specialNote = value;
                    },
                    decoration: InputDecoration(
                      labelText: "Instructions",
                      hintText: "Enter instructions (optional)",
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Add'),
                    onPressed: () {
                      PrescribeMedicineModel prescribedMedicine = PrescribeMedicineModel(
                        medicineDetails: medicine,
                        days: days,
                        intakeTime: {
                          'morning': morning,
                          'noon': noon,
                          'night': night,
                        },
                        isBeforeMeal: isBeforeMeal,
                        instruction: specialNote,
                      );
                      addPrescribedMedicine(patientId, prescribedMedicine);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}




