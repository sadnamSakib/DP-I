import 'dart:io';
import 'package:design_project_1/screens/authentication/Change%20Password.dart';
import 'package:design_project_1/screens/authentication/resetPassword.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:design_project_1/services/profileServices/Patient_profile_controller.dart';
import 'package:design_project_1/services/authServices/auth.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';
  String userName = '';
  String userInitial = '';

  final AuthService _auth = AuthService();

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference patients = FirebaseFirestore.instance.collection('patients');

  // Create a combined stream
  late Stream<DocumentSnapshot> combinedStream;

  @override
  void initState() {
    super.initState();
    fetchUserName();

    combinedStream = Rx.combineLatest2(
      users.doc(userUID).snapshots(),
      patients.doc(userUID).snapshots(),
          (userSnapshot, doctorSnapshot) {

        return userSnapshot;
      },
    );
  }

  Future<void> fetchUserName() async {
    try {
      final DocumentSnapshot userSnapshot = await users.doc(userUID).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final username = userData['name'];
        if (username != null) {
          setState(() {
            userName = username;
            userInitial = username[0].toUpperCase();

          });
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Text(
                userInitial,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text('Welcome $userName',
            overflow: TextOverflow.ellipsis),
          ],
        ),



        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body:


      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.blue.shade100],
          ),
        ),

        child: ChangeNotifierProvider(
          create: (_) => ProfileController(),
          child: Consumer<ProfileController>(
            builder: (context, provider, child) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: combinedStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData) {
                        Map<dynamic, dynamic>? userData = snapshot.data?.data() as Map<dynamic, dynamic>?;
                        String imageURL = userData?['profile'] ?? '';

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                    child: Center(
                                      child: Container(
                                        height: 130,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Color(0xFF2144F3),
                                            width: 5,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: provider.image == null
                                              ? (imageURL.isEmpty)
                                              ? Icon(Icons.person_2_outlined, size: 35)
                                              : Image.network(
                                            imageURL,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(child: CircularProgressIndicator());
                                            },
                                            errorBuilder: (context, object, stack) {
                                              return Container(
                                                child: Icon(Icons.error_outline, color: Colors.redAccent),
                                              );
                                            },
                                          )
                                              : Stack(
                                            children: [
                                              Image.file(
                                                File(provider.image!.path).absolute,
                                              ),
                                              Center(child: CircularProgressIndicator()),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      provider.pickImage(context);
                                    },
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.black,
                                      child: Icon(Icons.add, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              GestureDetector(
                                onTap: () {
                                  provider.showUserNameDialogueAlert(context, userData?['name'] ?? '');
                                },
                                child: ReusableRow(title: 'Username', value: userData?['name'], iconData: Icons.person_2_outlined),
                              ),
                              GestureDetector(
                                onTap: () {
                                  provider.showEmailDialogueAlert(context, userData?['email'] ?? '');
                                },
                                child: ReusableRow(title: 'Email', value: userData?['email'], iconData: Icons.email_outlined),
                              ),


                              StreamBuilder<DocumentSnapshot>(
                                stream: patients.doc(userUID).snapshots(),
                                builder: (context, patientSnapshot) {
                                  if (!patientSnapshot.hasData) {
                                    return Center(child: CircularProgressIndicator());

                                  } else if (patientSnapshot.hasData) {
                                    Map<dynamic, dynamic>? patientData = patientSnapshot.data?.data() as Map<dynamic, dynamic>?;
                                    List<dynamic>? diseaseList = patientData?['preExistingConditions'];

                                    List<String>? diseases = diseaseList?.map((degree) => degree.toString()).toList();

                                    String diseaseString = diseases?.join(', ') ?? 'N/A';
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            provider.showPhoneNumberDialogueAlert(context, userData?['phone'] ?? '');
                                          },

                                          child:
                                          ReusableRow(title: 'Phone', value: patientData?['phone'] ?? 'xxx-xxx-xxx', iconData: Icons.phone_android_rounded),
                                        ),
                                          GestureDetector(
                                          onTap: () {
                                          provider.showEmergencyContactDialogueAlert(context, patientData?['emergencyPhone'] ?? '');
                                          },

                                          child:
                                        ReusableRow(title: 'Emergency contact', value: patientData?['emergencyPhone'] ?? 'xxx-xxx-xxx', iconData: Icons.phone_android_rounded), // Add more rows as needed
                                          ),
                                          GestureDetector(
                                          onTap: () {
                                          provider.showAddressDialogueAlert(context, patientData?['address'] ?? '');
                                          },

                                          child:
                                        ReusableRow(title: 'Address', value: patientData?['address'] ?? 'xxx-xxx-xxx', iconData: Icons.house), // Add more rows as needed
                                          ),
                                        ReusableRow(
                                          title: 'Gender',
                                          value: patientData?['gender'] ?? 'xxx-xxx-xxx',
                                          iconData: patientData?['gender'] == 'Male' ? Icons.male : Icons.female,
                                        ),

                                        ReusableRow(title: 'Diseases', value: diseaseString, iconData: Icons.sick_outlined),
                                      ],


                                    );

                                  }
                                  else {
                                    return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.displayMedium));
                                  }
                                },
                              ),
                              SizedBox(height: 8),
                              Container(
                                child: ElevatedButton(
                                  onPressed: ()  {
                                    Navigator.push(
                                      context, MaterialPageRoute(builder: (context)
                                    {
                                      return ChangePassword();
                                    },
                                    ),
                                    );
                                  },
                                  child: Text(
                                    'Change Password',
                                    style: TextStyle(color: Colors.white), // Set the text color to black
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade900,
                                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    textStyle: TextStyle(fontSize: 18),
                                  ).copyWith(
                                    minimumSize: MaterialStateProperty.all(Size(double.infinity, 60)),
                                    backgroundColor: MaterialStateProperty.all(Colors.blue.shade900),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.displayMedium));
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}





class ReusableRow extends StatelessWidget {
  final String title;
  final String? value;
  final IconData iconData;

  ReusableRow({Key? key, required this.title, required this.iconData, this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              iconData,
              color: Colors.black,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (value != null)
                    if (value is List)
                      Column(
                        children: (value as List).map((item) {
                          return Text(item.toString());
                        }).toList(),
                      )
                    else
                      Text(value.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
