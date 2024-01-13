import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ProfileController with ChangeNotifier{

  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference patients = FirebaseFirestore.instance.collection('patients');

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();



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
      print(error.toString()); // Print for debugging
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
              }, child: Text('Cancel',
                  style: TextStyle(color: Colors.red)),
              ),

              TextButton(onPressed: () async {
                Navigator.pop(context);
                String newName = nameController.text;
                if (newName.isNotEmpty) {
                  try {
                    await users.doc(userUID).update({'name': newName});
                    await patients.doc(userUID).update({'name': newName});
                    nameController.clear();
                    Fluttertoast.showToast(
                      msg: 'Username updated',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.blue,
                    );
                  } catch (error) {
                    print('Error updating username: $error');

                  }
                }
              },
                  child: Text('OK')),
            ],
          );
        });
  }





  Future<void> showPhoneNumberDialogueAlert(BuildContext context, String phone) {
    PhoneNumber phoneNumber = PhoneNumber(isoCode: 'BD'); // You can set the default country ISO code

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update phone number'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    final formattedPhoneNumber = number.phoneNumber;
                    if (formattedPhoneNumber != null &&
                        formattedPhoneNumber.isNotEmpty &&
                        formattedPhoneNumber.length == 14 &&
                        formattedPhoneNumber.startsWith('+8801')) {
                      phoneNumber = number;
                    }
                  },
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                  ),
                  searchBoxDecoration: InputDecoration(
                    hintText: 'Search for a country',
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: Colors.black),
                  initialValue: phoneNumber,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                String? newPhoneNumber = phoneNumber.phoneNumber; // Get the valid phone number

                if (newPhoneNumber != null && newPhoneNumber.isNotEmpty) {
                  try {
                    await patients.doc(userUID).update({'phone': newPhoneNumber});
                    Fluttertoast.showToast(
                      msg: 'Phone number updated',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.blue,
                    );
                  } catch (error) {
                    print('Error updating phone number: $error');
                  }
                }
                else{
                  Fluttertoast.showToast(
                      msg: 'Invalid phone number',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.red,
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }








  Future<void> showEmailDialogueAlert(BuildContext context, String email) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Email'),
          content: Text('Your email cannot be changed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> showAddressDialogueAlert(BuildContext context, String address) {

    return showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Update address'),
            content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(labelText: 'New address'),
                    ),
                  ],
                )
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text('Cancel',
                  style: TextStyle(color: Colors.red)),
              ),

              TextButton(onPressed: () async {
                Navigator.pop(context);
                String newaddress = addressController.text;
                if (newaddress.isNotEmpty) {
                  try {
                    await patients.doc(userUID).update({'address': newaddress});
                    addressController.clear();
                    Fluttertoast.showToast(
                      msg: 'Address updated',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.blue,
                    );
                  } catch (error) {
                    print('Error updating address: $error');

                  }
                }
              },
                  child: Text('OK')),
            ],
          );
        });

  }


  Future<void> showEmergencyContactDialogueAlert(BuildContext context, String phone) {
    PhoneNumber phoneNumber = PhoneNumber(isoCode: 'BD'); // You can set the default country ISO code

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update phone number'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    final formattedPhoneNumber = number.phoneNumber;
                    if (formattedPhoneNumber != null &&
                        formattedPhoneNumber.isNotEmpty &&
                        formattedPhoneNumber.length == 14 &&
                        formattedPhoneNumber.startsWith('+8801')) {
                      phoneNumber = number;
                    }
                  },
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                  ),
                  searchBoxDecoration: InputDecoration(
                    hintText: 'Search for a country',
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: Colors.black),
                  initialValue: phoneNumber,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                String? newPhoneNumber = phoneNumber.phoneNumber; // Get the valid phone number

                if (newPhoneNumber != null && newPhoneNumber.isNotEmpty) {
                  try {
                    await patients.doc(userUID).update({'emergencyPhone': newPhoneNumber});
                    Fluttertoast.showToast(
                      msg: 'Contact updated',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.blue,
                    );
                  } catch (error) {
                    print('Error updating phone number: $error');
                  }
                }
                else{
                  Fluttertoast.showToast(
                    msg: 'Invalid contact number',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.red,
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }




}