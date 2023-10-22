import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/squareTile.dart';
import 'package:design_project_1/services/diseaseViewModel.dart';

import 'kidneyTrackerSummary/kidneyTrackerSummaryScreen.dart';


class HealthTrackersScreen extends StatefulWidget {
  final patientId;
  const HealthTrackersScreen({super.key, this.patientId});

  @override
  State<HealthTrackersScreen> createState() => _HealthTrackersScreenState();
}
class disease{
  String name;
  String icon;
  disease(this.name, this.icon);
}
class _HealthTrackersScreenState extends State<HealthTrackersScreen> {

  List<disease>selectedDiseases = [];
  @override
  void initState() {
    super.initState();
    _loadSelectedDiseases();
  }

  void _loadSelectedDiseases() {
    diseaseDatabaseService(uid: widget.patientId)
        .diseaseDoc
        .listen((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;

        List<disease> loadedDiseases = [
          disease(data['name'], data['icon'])
        ];

        setState(() {
          selectedDiseases = loadedDiseases;
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Disease Health Tracker'),

      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // colors: [Colors.white70, Colors.blue.shade200],
            colors: [Colors.white70, Colors.blue.shade200],
          ),
        ),
        child: selectedDiseases.isEmpty
            ? Center(
          child: Text(
            'No trackers for this patient',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: selectedDiseases.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 100,
                width: 100,
                child: GestureDetector(
                  onTap:
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => KidneyTrackerSummaryScreen()),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedDiseases[index].name,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50, // Adjust the height as needed
                            width: 50, // Adjust the width as needed
                            child: Image.asset(
                              selectedDiseases[index].icon, // Replace with your image path
                              fit: BoxFit.cover, // Adjust the fit as needed
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
