import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/Storage/Upload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../BookAppointment/doctorFinderPage.dart';
import 'DoctorswithAppointments.dart';
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
        allFilesData = filesSnapshot.docs
            .map((doc) {
          Map<String, dynamic> dataWithId = {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>
          };

          print('File ID: ${doc.id}');

          return dataWithId;
        })
            .toList();

        setState(() {});


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



  void pickFileForFolder() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc','img','png','jpg'],
    );

    if (pickedFile != null) {
      String originalFileName = pickedFile.files[0].name;
      String userID = userUID;


      File file = File(pickedFile.files[0].path!);
      final downloadLink = await uploadFile(originalFileName, file);

      _firebaseFirestore.collection("Documents").
      doc('Reports and Prescriptions')
          .collection(userUID)
          .doc(widget.folderName)
          .collection('Files').add({
        "name": originalFileName,
        "URL": downloadLink,
      });

      print("File UPLOADED SUCCESSFULLY");

      Fluttertoast.showToast(
        msg: 'File Uploaded',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.blue,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DoctorFinder()),
      );
    }
  }



  Future<String?> uploadFile(String fileName, File file) async{

    final reference = FirebaseStorage.instance.ref().child("Reports and Prescriptions/$fileName.pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() => {});

    final downloadLink = await reference.getDownloadURL();

    return downloadLink;

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
                      Center(
                        child: Text(
                           'Upload your files',
                          style: TextStyle(fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,),
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

                        onTap: () async {
                          String fileName = allFilesData[index]['name'];
                          String fileURL = allFilesData[index]['URL'];

                          _createSharedDocumentDialogueBox(fileName,fileURL);
                        },
                        onLongPress: () {
                          _showDeleteConfirmationDialog(allFilesData[index]['id']);
                        },
                        child:

                        Container(
                          margin: EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.file_copy_outlined,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        allFilesData[index]['name'],
                                        style: TextStyle(color: Colors.black,  fontSize: 18),
                                      ),
                                      SizedBox(height: 8),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                      ),
                    );



                  }
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
                          pickFileForFolder();
                          Navigator.pop(context);



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

  Future<void> _showDeleteConfirmationDialog(String fileId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete File'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this file?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                  deleteFile(fileId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createSharedDocumentDialogueBox(String fileName,String fileURL) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share Document'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Share this file with your doctors.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                shareDocument(fileName,fileURL);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  Future<void> deleteFile(String fileID) async {
    try {
      print(fileID);
      await _firebaseFirestore
          .collection("Documents")
          .doc('Reports and Prescriptions')
          .collection(userUID)
          .doc(widget.folderName)
          .collection('Files')
          .doc(fileID)
          .get()
          .then((doc) async {
        if (doc.exists) {

          await doc.reference.delete();

          String fileURL = doc['URL'];
          Reference storageRef = FirebaseStorage.instance.refFromURL(fileURL);
          await storageRef.delete();

          print("File deleted successfully");
          Fluttertoast.showToast(
            msg: 'File Deleted',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.blue,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UploadFile()),
          );
        } else {
          print('File not found');
        }
      });
    } catch (error) {
      print("Error deleting file: $error");
    }
  }


  Future<void> shareDocument(String fileName, String fileURL) async {

    List<String> doctorIds = await getDoctorIdsForPatient();
    for (String doctorId in doctorIds) {
      print('DOCTOR ID: $doctorId');
    }


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => DoctorswithAppointments(doctorIds: doctorIds, fileName: fileName,
            fileURL: fileURL),
      ),
    );
  }




  Future<List<String>> getDoctorIdsForPatient() async {
    try {
      CollectionReference appointmentsCollection =
      FirebaseFirestore.instance.collection('Appointments');

      QuerySnapshot querySnapshot = await appointmentsCollection
          .where('patientId', isEqualTo: userUID)
          .get();

      Set<String> uniqueDoctorIds = Set<String>();

      querySnapshot.docs.forEach((doc) {
        uniqueDoctorIds.add(doc['doctorId'] as String);
      });

      List<String> doctorIds = uniqueDoctorIds.toList();

      return doctorIds;
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

}

