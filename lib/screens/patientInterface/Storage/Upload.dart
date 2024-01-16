import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/Storage/DoctorswithAppointments.dart';
import 'package:design_project_1/screens/patientInterface/Storage/FileViewer.dart';
import 'package:design_project_1/screens/patientInterface/Storage/Folder.dart';
import 'package:design_project_1/screens/patientInterface/home/home.dart';
import 'package:design_project_1/screens/patientInterface/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/AppointmentModel.dart';
import '../../../services/storageServices/UploadFiles.dart';
import '../BookAppointment/doctorFinderPage.dart';

        class UploadFile extends StatefulWidget {
          const UploadFile({super.key});

          @override
          State<UploadFile> createState() => _UploadFileState();
        }

        class _UploadFileState extends State<UploadFile> {

          TextEditingController folderNameController = TextEditingController();
          String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';
          bool doesCollectionExist = false;
          late Future<QuerySnapshot> collectionSnapshot;

          final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
        List<Map<String,dynamic>> fileData =[];


          Future<void> createFolder(String folderName) async {

            await _firebaseFirestore
                .collection('Documents')
            .doc('Reports and Prescriptions')
                .collection(userUID)
                .doc(folderName).set({})
               ;

            await _firebaseFirestore
                .collection('patients')
                .doc(userUID)
                .set({'documents': true}, SetOptions(merge: true));

          }

          Future<void> deleteFolder(String folderName) async {

            final CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance
                .collection('Documents')
                .doc('Reports and Prescriptions')
                .collection(userUID)
                .doc(folderName)
                .collection('Files');

            try {
              final QuerySnapshot<Map<String, dynamic>> documentsSnapshot =
              await collectionRef.get();


              final WriteBatch batch = FirebaseFirestore.instance.batch();
              documentsSnapshot.docs.forEach((doc) async {
                batch.delete(doc.reference);
                String fileURL = doc['URL'];
                Reference storageRef = FirebaseStorage.instance.refFromURL(fileURL);
                await storageRef.delete();
              });
              await batch.commit();

              await collectionRef.parent!.delete();


              print("Collection '$folderName' deleted successfully.");
              Fluttertoast.showToast(
                msg: 'Folder Deleted',
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

            } catch (error) {
              print("Error deleting collection '$folderName': $error");
            }
          }



          void getFiles() async {
            try {
              String userID = userUID;

              final files = await _firebaseFirestore
                  .collection("Documents")
                  .where('name', isGreaterThanOrEqualTo: '$userID')
                  .where('name', isLessThan: '$userID' + 'z')
                  .get();

              if (files.docs.isNotEmpty) {
                fileData = files.docs
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


                for (var data in fileData) {
                  print('File Data: $data');
                }

                print('All Files Data: $fileData');
              } else {
                print('No documents found in the Documents collection.');
              }
            } catch (e) {
              print('Error retrieving files data: $e');
            }
          }

          @override
          void initState() {
            super.initState();
            initializeData();
            getFiles();
          }

          Future<void> initializeData() async {


             QuerySnapshot collectionSnapshot = await _firebaseFirestore
                .collection('Documents')
                .doc('Reports and Prescriptions')
                .collection(userUID)
                .get();

            doesCollectionExist = collectionSnapshot.docs.isNotEmpty;

            if(doesCollectionExist){
              for (QueryDocumentSnapshot doc in collectionSnapshot.docs) {
                print('Document ID: ${doc.id}');
              }
            }

            print('Does collection exist? $doesCollectionExist');

          }


          @override
          Widget build(BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blue.shade900,
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Reports and Prescriptions'),
                ),
              ),
              body: Container(
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
                    FutureBuilder<QuerySnapshot>(
                      future: _firebaseFirestore
                          .collection('Documents')
                          .doc('Reports and Prescriptions')
                          .collection(userUID)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if ((!snapshot.hasData || snapshot.data!.docs.isEmpty) && fileData.isEmpty) {
                          return Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 20),
                                    Center(
                                      child: Text(
                                        'Create folders or Upload your files',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }


                        else {
                          var collectionSnapshot = snapshot.data!;
                          return Expanded(
                            child: PageView.builder(
                              itemCount: 2,
                              controller: PageController(viewportFraction: 1),
                              itemBuilder: (context, pageIndex) {
                                if (pageIndex == 0) {
                                  if (collectionSnapshot.docs.isEmpty) {

                                    return Center(
                                      child:  Text(
                                        'Create your folders',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  } else {
                                    /// Show the ListView.builder for folders
                                    return ListView.builder(
                                      itemCount: collectionSnapshot.docs.length,
                                      itemBuilder: (context, index) {
                                        int folderIndex = index;
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () {
                                              String collectionName = collectionSnapshot.docs[folderIndex].id;
                                              print('Tapped on collection: $collectionName');
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => NewFolder(folderName: collectionName)),
                                              );

                                            },
                                            onLongPress: () {
                                              String collectionName = collectionSnapshot.docs[folderIndex].id;
                                              print('Tapped on collection: $collectionName');
                                              _showDeleteFolderConfirmationDialog(collectionSnapshot.docs[folderIndex].id);
                                            },
                                            child:

                                            Container(
                                                // height: 50,
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
                                                      Icons.folder,
                                                      color: Colors.black,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            collectionSnapshot.docs[folderIndex].id,
                                                            style: TextStyle(color: Colors.black, fontSize: 18),
                                                          ),

                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )

                                          ),
                                        );
                                      },
                                    );
                                  }


                                } else {

                                    if (fileData.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'Create your files',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }

                                    else
                                    {
                                      return ListView.builder(
                                        itemCount: fileData.length,
                                        itemBuilder: (context, index) {
                                          int fileIndex = index;
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onDoubleTap: () {
                                                String fileName = fileData[fileIndex]['name'];
                                                String fileURL = fileData[fileIndex]['URL'];
                                                String originalFileName = fileName.split('_').skip(1).join('_');
                                                print('Tapped on file: $originalFileName, URL: $fileURL');
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => FileViewer(URL: fileURL)),
                                                );
                                              },
                                              onTap: () async {
                                                String fileName = fileData[fileIndex]['name'];
                                                String fileURL = fileData[fileIndex]['URL'];
                                                String originalFileName = fileName.split('_').skip(1).join('_');
                                                print('Tapped on file: $originalFileName, URL: $fileURL');

                                                _createSharedDocumentDialogueBox(originalFileName,fileURL);

                                              },

                                              onLongPress: () {
                                                _showDeleteConfirmationDialog(fileData[fileIndex]['id']);
                                              },
                                              child:

                                              Container(
                                                // height: 50,
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
                                                          fileData[fileIndex]['name'].split('_').skip(1).join('_'),

                                                         style: TextStyle(color: Colors.black, fontSize: 18),
                                                            ),


                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  // Display file data


                                }
                              },
                            ),
                          );
                        }

                      },
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
                              leading: Icon(Icons.create_new_folder),
                              
                              title: Text('Create a Folder'),
                              onTap: () {
                                Navigator.pop(context);
                                _showCreateFolderDialog();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => UploadFile()),
                                );
                              },
                            ),
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

          void _showCreateFolderDialog() {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Create a Folder'),
                  content: TextFormField(
                    controller: folderNameController,
                    decoration: InputDecoration(labelText: 'Folder Name'),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        String folderName = folderNameController.text;
                       
                        print('FOLDER NAME: $folderName');
                        createFolder(folderName);
                      },
                      child: Text('Create'),
                    ),
                  ],
                );
              },
            );
          }

          Future<void> _showDeleteConfirmationDialog(String fileName) async {
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
                        deleteFile(fileName);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }

          Future<void> _showDeleteFolderConfirmationDialog(String fileName) async {
            return showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete Folder'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('Are you sure you want to delete this folder?'),
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
                        // Perform delete operation
                        deleteFolder(fileName);
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
                        // Perform delete operation
                        shareDocument(fileName,fileURL);
                        Navigator.of(context).pop();
                        // initState();
                      },
                    ),
                  ],
                );
              },
            );
          }



          Future<void> deleteFile(String fileId) async {
            try {

              DocumentReference fileRef = _firebaseFirestore.collection("Documents").doc(fileId);


              DocumentSnapshot fileDoc = await fileRef.get();


              if (fileDoc.exists) {

                String fileURL = fileDoc['URL'];


                Reference storageRef = FirebaseStorage.instance.refFromURL(fileURL);


                await fileRef.delete();


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
                print('File not found in Firestore');
              }
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

              List<String> doctorIds = querySnapshot.docs
                  .map((doc) => doc['doctorId'] as String)
                  .toList();


              return doctorIds;
            } catch (e) {
              print('Error fetching appointments: $e');
              return [];
            }
          }
        }

