import 'package:design_project_1/screens/authentication/authenticate.dart';
import 'package:design_project_1/screens/authentication/chooseRole.dart';
import 'package:design_project_1/screens/doctorInterface/home/home.dart' as doctorHome;
import 'package:design_project_1/screens/patientInterface/home/home.dart' as patientHome;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/UserModel.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/authentication/doctorDetailsPage.dart' as doctordetails;
import 'package:design_project_1/screens/authentication/patientDetailsPage.dart' as patientdetails;

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        print(user.toString());

        if (user == null) {
          return const Authenticate();
          // return  doctorHome.Home();
        } else if (!user.emailVerified) {
          return const Authenticate();
        } else {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SpinKitCircle(
                    color: Colors.blue, // Choose your desired color
                    size: 50.0, // Choose the size of the indicator
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              if (userData == null) {
                // Handle the case when userData is null, e.g., by returning an error message or redirecting to a login page.
                return const Authenticate();
              }
              final userRole = userData['role'] as String?;

              // Fetch doctor and patient documents
              final doctorFuture = FirebaseFirestore.instance.collection('doctors').doc(user.uid).get();
              final patientFuture = FirebaseFirestore.instance.collection('patients').doc(user.uid).get();

              return FutureBuilder<DocumentSnapshot>(
                future: userRole == 'doctor' ? doctorFuture : patientFuture,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitCircle(
                        color: Colors.blue, // Choose your desired color
                        size: 50.0, // Choose the size of the indicator
                      ),
                    );
                  }


                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (userRole == 'doctor' && snapshot.data!.data()== null) {
                    return doctordetails.DoctorDetailsPage();
                  } else if (userRole == 'patient' && snapshot.data!.data()== null) {
                    return patientdetails.PatientDetailsPage();
                  }
                  else if(userRole == 'patient'){
                    print(userRole.toString());

                    return patientHome.Home();
                  }
                  else if (userRole == 'doctor') {
                    return doctorHome.Home();
                  }
                  else {
                    return RoleSelectionPage();
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}
