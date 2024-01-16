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
  List<Medicine> prescribedMedicines = [];


  @override
  void initState() {
    super.initState();
    loadMedicines().then((value) {
      setState(() {
        medicines = value;
      });
    });
    // loadCurrentlyRunningMedicines(widget.patientId).then((value) {
    //   setState(() {
    //     print(value);
    //     prescribedMedicines = value;
    //     print(prescribedMedicines.length);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Search Medicine'),
        backgroundColor: Colors.pink.shade900,
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
                    _showPrescribeMedicineModalBottomSheet(context, searchResults[index] , widget.patientId, (value) {
                      setState(() {
                        prescribedMedicines = value;
                      });
                    });
                  }
                );
              },
            ),
            Padding(padding:
              EdgeInsets.all(8.0),
              child: Text('Currently Prescribed Medicines', style: TextStyle(fontSize: 20.0),),
            ),
            StreamBuilder<List<Medicine>>(
              stream: loadCurrentlyRunningMedicines(widget.patientId),
              builder: (BuildContext context, AsyncSnapshot<List<Medicine>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Text('Loading...');
                  default:
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index].brandName + ' ' + snapshot.data![index].strength),
                          subtitle: Text(snapshot.data![index].generic ),
                        );
                      },
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showPrescribeMedicineModalBottomSheet(BuildContext context, Medicine medicine , String patientId,Function(List<Medicine>) updatePrescribedMedicines) {
  bool morning = false;
  bool noon = false;
  bool night = false;
  bool isBeforeMeal = true;
  int days = 0;
  String specialNote = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      int morning = 0;
      int noon = 0;
      int night = 0;
      bool isBeforeMeal = true;
      int days = 0;
      String specialNote = '';


      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Morning'),
                    trailing: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Expanded(
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                setState(() {
                                  if (morning > 0) {
                                    morning--;
                                  }
                                });
                              },
                            ),
                            Text('$morning'),
                            IconButton(
                              icon: Icon(Icons.add_circle),
                              onPressed: () {
                                setState(() {
                                  morning++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Noon'),
                    trailing: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Expanded(
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                setState(() {
                                  if (noon > 0) {
                                    noon--;
                                  }
                                });
                              },
                            ),
                            Text('$noon'),
                            IconButton(
                              icon: Icon(Icons.add_circle),
                              onPressed: () {
                                setState(() {
                                  noon++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Night'),
                    trailing: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Expanded(
                        child: Row(
                          children: <Widget>[

                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                setState(() {
                                  if (night > 0) {
                                    night--;
                                  }
                                });
                              },
                            ),
                            Text('$night'),
                            IconButton(
                              icon: Icon(Icons.add_circle),
                              onPressed: () {
                                setState(() {
                                  night++;
                                });
                              },
                            ),

                          ],
                        ),
                      ),
                    ),
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
                      if (morning == 0 && noon == 0 && night == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please update the intake time.'))
                        );
                        return;
                      }

                      if (days == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please update the number of days.'))
                        );
                        return;
                      }


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
                      // loadCurrentlyRunningMedicines(patientId).then((value) {
                      //   updatePrescribedMedicines(value);
                      // });

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




