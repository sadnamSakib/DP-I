import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../patientInterface/Storage/FileViewer.dart';


class ReportsandPrescriptions extends StatefulWidget {
  final String patientID;

  const ReportsandPrescriptions({Key? key, required this.patientID}) : super(key: key);


  @override
  State<ReportsandPrescriptions> createState() => _ReportsandPrescriptionsState();
}

class _ReportsandPrescriptionsState extends State<ReportsandPrescriptions> {

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Map<String, dynamic>> allFilesData=[];

  Future<void> getFiles() async {
    try {

      QuerySnapshot filesSnapshot = await FirebaseFirestore.instance
          .collection('Documents')
          .doc('Shared Documents')
          .collection(widget.patientID)
          .doc(userUID)
          .collection('Files')
          .get();

      if (filesSnapshot.docs.isNotEmpty) {
        allFilesData = filesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {

        });

        for (var data in allFilesData) {
          print('File Data: $data');
        }

        print('All Files Data: $allFilesData');
      } else {
        print('No documents found in the Files subcollection.');
      }
    } catch (e) {
      print('Error retrieving files data: $e');
    }
  }

  @override
  void initState()
  {
    super.initState();
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

        appBar: AppBar(
          title: Text('Reports and Prescriptions'),
          backgroundColor: Colors.blue.shade900,
        ),
        body:  Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white70, Colors.pink.shade50],
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              allFilesData.isEmpty
                  ? Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'No shared Reports and Prescriptions',
                            style: TextStyle(fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                            textAlign: TextAlign.center,),
                        ),
                      ],),
                  ),
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: allFilesData.length,
                  itemBuilder: (context, index) {
                    if (index < allFilesData.length) {
                      // Display file data
                      String fileName = allFilesData[index]['name'];
                      String fileURL = allFilesData[index]['URL'];
                      return

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onDoubleTap: () {
                              print('Tapped on file: $fileName, URL: $fileURL');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FileViewer(URL: fileURL),
                                ),
                              );
                            },

                            child: Card(
                              color: Colors.white,
                              child: ListTile(
                                leading: Icon(Icons.file_copy),
                                title: Text(
                                  allFilesData[index]['name'],
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        );



                    }
                  },
                ),
              ),
            ],
          ),
        )
    );
  }


}
