import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/utilities/squareTile.dart';
import 'package:design_project_1/models/diseaseViewModel.dart';

import 'kidneyDiseaseTracker/kidneyTracker.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}
class disease{
  String name;
  String icon;
  disease(this.name, this.icon);
}
class _TrackerState extends State<Tracker> {
  List<disease> availableDiseases = [disease('Kidney Disease', 'assets/images/kidney.png'), disease('Diabetes', 'assets/images/diabetes.png'), disease('Heart Disease', 'assets/images/heart.png')];
  List<disease>selectedDiseases = [];
  @override
  void initState() {
    super.initState();
    _loadSelectedDiseases();
  }

  void _loadSelectedDiseases() {
    diseaseDatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
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
          for(disease d in selectedDiseases){
            availableDiseases.removeWhere((element) => element.name == d.name);
          }
        });
      }
    });
  }

  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: ListView(
            children: <Widget>[
              for (disease d in availableDiseases)
                ListTile(
                  title: Text(d.name,
                      style: TextStyle(
                        fontSize: 20,
                      )),
                  onTap: () {
                    setState(() async {
                      if (d.name == 'Kidney Disease') {
                        setState(() async {
                          await diseaseDatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createKidneyDiseaseData(d.name, d.icon);
                          _loadSelectedDiseases();
                          availableDiseases.remove(d);
                          Navigator.pop(context);
                        });
                      }
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Disease Tracker'),

      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // colors: [Colors.white70, Colors.blue.shade200],
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),
        child: selectedDiseases.isEmpty
            ? Center(
          child: Text(
            'Add diseases to track by pressing the button below',
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
                  onLongPress: () {
                    // Show delete option
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Disease?'),
                          content: Text('Are you sure you want to delete this disease?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  availableDiseases.add(selectedDiseases[index]);
                                  selectedDiseases.removeAt(index);
                                  diseaseDatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).deleteKidneyDiseaseData();
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onTap:
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const KidneyTracker()),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        onPressed: () {
          _openModal(context);
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
