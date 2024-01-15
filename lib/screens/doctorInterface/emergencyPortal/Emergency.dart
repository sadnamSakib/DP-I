import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/emergencyPortal/emergencyRequests.dart';
import 'package:design_project_1/screens/doctorInterface/home/Feed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../services/authServices/auth.dart';

class Emergency extends StatefulWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  State<Emergency> createState() => _EmergencyState();
}

Stream<DocumentSnapshot> getDoctorData() {
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  return FirebaseFirestore.instance.collection('doctors').doc(userUID).snapshots();

}
void updateEmergencyStatus() async {
  try {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    DocumentReference doctorRef = FirebaseFirestore.instance.collection('doctors').doc(userUID);

    DocumentSnapshot doctorSnapshot = await doctorRef.get();

    if (doctorSnapshot.exists) {

      await doctorRef.update({'emergency': true});
      print('Doctor document updated successfully!');

    } else {
      print('Doctor document does not exist.');
    }
  } catch (error) {
    print('Error updating doctor document: $error');
  }

}

class _EmergencyState extends State<Emergency> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink.shade900,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text('DocLinkr'),

          ),
        ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Join Our Team of Emergency Doctors!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'At DocLinkr, we value your expertise and commitment to saving lives. '
                      'Join our team of dedicated emergency doctors and make a significant impact on the well-being of community.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                Text(
                  'Benefits of Enrolling:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 10),
                Text(
                  '1. Opportunities to contribute to critical and life-saving situations.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  '2. Collaborate with a team of skilled healthcare professionals.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  '3. Continuous learning and professional development.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 10,),
                Text(
                  'Wht do you have to do?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 10),
                Text(
                  '1. Dedicate more of your valuable time to us.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  '2. Attend to the patients of emergency need. You might need to engage in voice call and emergency '
                      'chat rooms.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 10,),
                Text(
              'We value your time and committment. Tap on \'Agree\' to continue',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.bold,

              ),
              textAlign: TextAlign.left,
            ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {

                        updateEmergencyStatus();
                        print('Accepted');
                        Fluttertoast.showToast(
                          msg: 'You are now enlisted in Emergency Panel.',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.blue,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => EmergencyRequestList()),
                        );
                      },
                      child: Text('Accept'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        print('Declined');

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Feed()),
                        );
                      },
                      child: Text('Decline'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
