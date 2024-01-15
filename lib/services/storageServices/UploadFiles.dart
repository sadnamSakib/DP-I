import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UploadFiles{
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<String?> uploadFile(String fileName, File file) async{

    final reference = FirebaseStorage.instance.ref().child("Reports and Prescriptions/$fileName");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() => {});

    final downloadLink = await reference.getDownloadURL();

    return downloadLink;

  }

  void pickFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc','img','png','jpg'],
    );

    if (pickedFile != null) {
      String originalFileName = pickedFile.files[0].name;
      String userID = userUID;

      String fileName = "$userID" + "_" + originalFileName;

      File file = File(pickedFile.files[0].path!);
      final downloadLink = await uploadFile(fileName, file);

      _firebaseFirestore.collection("Documents").add({
        "name": fileName,
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


    }
  }

}