        import 'dart:io';
        import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/Storage/DisplayFolderName.dart';
        import 'package:design_project_1/screens/patientInterface/Storage/FileViewer.dart';
import 'package:design_project_1/screens/patientInterface/profile/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
        import 'package:firebase_messaging/firebase_messaging.dart';
        import 'package:firebase_storage/firebase_storage.dart';
        import 'package:flutter/cupertino.dart';
        import 'package:flutter/material.dart';
        import 'package:file_picker/file_picker.dart';
        import 'package:flutter/material.dart';

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
                .collection('Documents')  // Parent collection
            .doc('Reports and Prescriptions')
                .collection(userUID)  // User's UID document
                .doc(folderName).set({}) // Folder name collection
               ;

            await _firebaseFirestore
                .collection('patients')  // Doctors collection
                .doc(userUID)  // User's UID document
                .set({'documents': true}, SetOptions(merge: true));

            initState();
          }

          Future<String?> uploadFile(String fileName, File file) async{

            final reference = FirebaseStorage.instance.ref().child("Reports/$fileName.pdf");

            final uploadTask = reference.putFile(file);

            await uploadTask.whenComplete(() => {});

            final downloadLink = await reference.getDownloadURL();

            return downloadLink;

          }

        void pickFile() async{


            final pickedFile = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf','txt','doc'],
            );

            if(pickedFile != null)
              {
                String fileName = pickedFile.files[0].name;
                File file = File(pickedFile.files[0].path!);
                final downloadLink = await uploadFile(fileName, file);

        _firebaseFirestore.collection("Documents").add({
          "name": fileName,
          "URL": downloadLink,
        });

        print("File UPLOADED SUCCESSFULLY");
              }



        }

        void getFiles() async {
            final files = await _firebaseFirestore.collection("Documents").get();

            fileData= files.docs.map((e) => e.data()).toList();

            setState(() {
            });

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
              // getFiles();
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
                  child: Text('DocLinkr'),
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
                        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty || fileData.isEmpty) {
                          return Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              alignment: Alignment.center,
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 20),
                                    Text(
                                      'Create folders or Upload your files',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          var collectionSnapshot = snapshot.data!;
                          return Expanded(
                            child: ListView.builder(
                              itemCount: fileData.length + collectionSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                if (index < fileData.length) {
                                  // Display file data
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        // Handle tapping on the file
                                        String fileName = fileData[index]['name'];
                                        String fileURL = fileData[index]['URL'];
                                        print('Tapped on file: $fileName, URL: $fileURL');
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => FileViewer(URL: fileURL)),
                                        );
                                        // Navigate or perform other actions as needed
                                      },
                                      child: DisplayFolderName(
                                        title: fileData[index]['name'],

                                      ),
                                    ),
                                  );
                                } else {
                                  // Display folder names
                                  int folderIndex = index - fileData.length;
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        // Handle tapping on the folder
                                        String collectionName = collectionSnapshot.docs[folderIndex].id;
                                        print('Tapped on collection: $collectionName');
                                        // Navigate or perform other actions as needed
                                      },
                                      child: DisplayFolderName(
                                        title: collectionSnapshot.docs[folderIndex].id,
                                      ),
                                    ),
                                  );
                                }
                              },
                            )

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
                                Navigator.pop(context); // Close the bottom sheet
                                _showCreateFolderDialog(); // Show the folder creation dialog
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
                                Navigator.pop(context); // Close the bottom sheet
                                pickFile(); // Perform file picking logic
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
            ;
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
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                        String folderName = folderNameController.text;
                       
                        print('FOLDER NAMEE: $folderName');
                        createFolder(folderName);
                      },
                      child: Text('Create'),
                    ),
                  ],
                );
              },
            );
          }
        }

