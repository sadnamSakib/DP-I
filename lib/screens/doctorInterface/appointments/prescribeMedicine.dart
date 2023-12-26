import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:design_project_1/services/medicineServices/medicines.dart';
import 'package:design_project_1/services/medicineServices/Medicine.dart';

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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
