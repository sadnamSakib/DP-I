import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';

class ProfileController with ChangeNotifier{

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  final nameController = TextEditingController();
  final phoneContoller = TextEditingController();

  final nameFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();

  final picker = ImagePicker();
  XFile? _image ;
  XFile? get image => _image;

  bool _loading =false;
  bool get loading => _loading;
  setLoading(bool value){
    _loading=value;
    notifyListeners();
  }
  
  Future pickGalleryImage(BuildContext context)async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery , imageQuality: 100);

     if(pickedFile != null)
       {
         _image = XFile(pickedFile.path);
         uploadImage(context);
         notifyListeners();
       }
  }

  Future pickCameraImage(BuildContext context)async{
    final pickedFile = await picker.pickImage(source: ImageSource.camera , imageQuality: 100);

    if(pickedFile != null)
    {
      _image = XFile(pickedFile.path);
      uploadImage(context);
      notifyListeners();
    }
  }

  void pickImage(context)
  {
    showDialog(
        context: context,
        builder: (BuildContext context){
      return AlertDialog(
        content: Container(
          height:120,
          child: Column(
            children: [
              ListTile(
                onTap: (){
                pickCameraImage(context);
                Navigator.pop(context);
                },
                leading: Icon(Icons.camera, color: Colors.black),
                title: Text('Camera'),

              ),
              ListTile(
                onTap: (){
                  Navigator.pop(context);
                  pickGalleryImage(context);
                },
                leading: Icon(Icons.picture_in_picture, color: Colors.black),
                title: Text('Gallery'),

              )
            ],
          )
        ),
      );
    }
    );
  }

  void uploadImage(BuildContext context) async{

    setLoading(true);
    firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref('/image/$userUID');
    firebase_storage.UploadTask uploadTask =  storageRef.putFile(File(image!.path).absolute);

    await Future.value(uploadTask);
    final newURL = await storageRef.getDownloadURL();

    try {
      await uploadTask;
      final newURL = await storageRef.getDownloadURL();
      await users.doc(userUID).update({
        'profile': newURL.toString(),
      });
      Fluttertoast.showToast(
        msg: 'Image updated',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.blue,
      );
      setLoading(false);
      _image = null;
    } catch (error) {
      print(error.toString()); // Print the error for debugging
      // Fluttertoast.showToast(
      //   msg: 'Failed to update image',
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.white,
      //   textColor: Colors.red,
      // );
      setLoading(false);
      _image = null;
    }

  }

  Future<void> showUserNameDialogueAlert(BuildContext context, String name) {

    return showDialog(context: context,
        builder: (context){
      return AlertDialog(
        title: Text('Update username'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'New Username'),
              ),
            ],
          )
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text('Cancel')),

          TextButton(onPressed: (){
            Navigator.pop(context);
            String newName = nameController.text;
            if(newName.isNotEmpty){
              users.doc(userUID).update({
                'name': newName,
              }).then((_) {
                // Username updated successfully
                nameController.clear(); // Clear the input field
                Navigator.pop(context); // Close the dialog
              }).catchError((error) {
                // Handle any errors that may occur during the update
                print('Error updating username: $error');
                // You can show an error message to the user if needed
              });
            }
          },child: Text('OK')),
        ],
      );
        });
  }
}