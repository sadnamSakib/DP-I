import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../services/UploadFiles.dart';
import '../BookAppointment/doctorFinderPage.dart';
import 'DisplayFolderName.dart';
import 'FileViewer.dart';

class NewFolder extends StatefulWidget {
  final String folderName;

  const NewFolder({Key? key, required this.folderName}) : super(key: key);

  @override
  State<NewFolder> createState() => _NewFolderState();
}

class _NewFolderState extends State<NewFolder> {

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool doesCollectionExist = false;
  late Future<QuerySnapshot> collectionSnapshot;
   List<Map<String, dynamic>> allFilesData=[];
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String,dynamic>> fileData =[];

  @override
  void initState(){
    super.initState();
    getFiles();
  }

  Future<void> getFiles() async {
    try {
      QuerySnapshot filesSnapshot = await FirebaseFirestore.instance
          .collection('Documents')
          .doc('Reports and Prescriptions')
          .collection(userUID)
          .doc(widget.folderName)
          .collection('Files')
          .get();

      if (filesSnapshot.docs.isNotEmpty) {
        // Retrieve and process data from each document in the subcollection
        allFilesData = filesSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {

        });

        // Print data for debugging
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.folderName),
        ),
      ),
      body:  Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.blue.shade100],
          ),
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
                      Text(
                  'Create folders or Upload your files',
                        style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,),
                        textAlign: TextAlign.center,),
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
                    Padding(padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        print('Tapped on file: $fileName, URL: $fileURL');
                  Navigator.pushReplacement(
                  context,
                    MaterialPageRoute(
                      builder: (context) => FileViewer(URL: fileURL),
                    ),);
                  },
                      child: DisplayFolderName(
                        title: allFilesData[index]['name'],
                      ),
                    ),
                  );}
                  },
              ),
            ),
          ],
        ),
      ),


        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[

                      ListTile(
                        leading: Icon(Icons.file_upload),
                        title: Text('Upload a File'),
                        onTap: () {
                          UploadFiles().pickFile();


                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DoctorFinder()),
                          );


                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
    );
  }
}