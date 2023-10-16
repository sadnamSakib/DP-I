import 'package:design_project_1/screens/authentication/authenticate.dart';
import 'package:design_project_1/screens/authentication/chooseRole.dart';
import 'package:design_project_1/screens/doctorInterface/home/home.dart' as doctorHome;
import 'package:design_project_1/screens/patientInterface/home/home.dart' as patientHome;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return const Authenticate();
        } else if (!user.emailVerified) {
          return const Authenticate();
        } else {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>;
              final userRole = userData['role'] as String?;

              if (userRole == null) {
                return RoleSelectionPage();
              } else if (userRole == 'doctor') {
                return doctorHome.Home();
              } else {
                return patientHome.Home();
              }
            },
          );
        }
      },
    );
  }
}
