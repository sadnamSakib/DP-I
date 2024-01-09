import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/patientInterface/Storage/FileViewer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadFile extends StatefulWidget {
  const UploadFile({super.key});

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
List<Map<String,dynamic>> fileData =[];

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
  void initState(){
    super.initState();
    getFiles();

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
            fileData.isEmpty
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
            )
                : Expanded(
              child: ListView.builder(
                itemCount: fileData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                        FileViewer(URL: fileData[index]['URL'])),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset("assets/images/pdf.png",
                            height: 100,
                              width:80,),
                              Text(
                               fileData[index]['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              )
                          ],
                        ),
                      ),
                    )
                    // Add more details or actions as needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          pickFile();
        },
      ),
    )

    ;
  }
}