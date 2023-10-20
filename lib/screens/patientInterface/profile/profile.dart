import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:design_project_1/services/Patient_profile_controller.dart';
import 'package:design_project_1/services/auth.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  final AuthService _auth = AuthService();

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference patients = FirebaseFirestore.instance.collection('patients');

  // Create a combined stream
  late Stream<DocumentSnapshot> combinedStream;

  @override
  void initState() {
    super.initState();

    // Merge the streams using rxdart's StreamGroup
    combinedStream = Rx.combineLatest2(
      users.doc(userUID).snapshots(),
      patients.doc(userUID).snapshots(),
          (userSnapshot, doctorSnapshot) {

        return userSnapshot;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text('DocLinkr'),
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
          color: Colors.lightBlue.shade50,

          image: DecorationImage(
            image: AssetImage('assets/images/doc.png'), //
            fit: BoxFit.fitHeight,
            opacity: .2,
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
                                        ReusableRow(title: 'Diseases', value: diseaseString, iconData: Icons.sick_outlined),
                                      ],
                                    );

                                  }
                                  else {
                                    return Center(child: Text('Something went wrong', style: Theme.of(context).textTheme.displayMedium));
                                  }
                                },
                              ),
                              // SizedBox(height: 8),
                              // // Your Logout Button
                              // Padding(
                              //   padding: EdgeInsets.only(bottom: 20),
                              //   child: ElevatedButton(
                              //     onPressed: () async {
                              //       await _auth.signOut();
                              //     },
                              //     child: Text('Logout'),
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: Colors.blueGrey, // Background color
                              //       padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              //       textStyle: TextStyle(fontSize: 18),
                              //     ).copyWith(
                              //       minimumSize: MaterialStateProperty.all(Size(double.infinity, 60)),
                              //       backgroundColor: MaterialStateProperty.all(Colors.blueGrey), // Background color
                              //     ),
                              //   ),
                              // ),
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
