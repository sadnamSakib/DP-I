import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/screens/doctorInterface/home/Emergency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/authServices/auth.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();

}


Stream<DocumentSnapshot> getUserData() {
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  return FirebaseFirestore.instance.collection('users').doc(userUID).snapshots();

}

Stream<DocumentSnapshot> getDoctorData() {
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  return FirebaseFirestore.instance.collection('doctors').doc(userUID).snapshots();

}

class _FeedState extends State<Feed> {

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
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter, // 10% of the width, so there are ten blinds.
            colors: [Colors.white70, Colors.pink.shade50], // whitish to gray// repeats the gradient over the canvas
          ),
        ),

          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: getUserData(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final userData = snapshot.data?.data() as Map<String, dynamic>;
                    final username = userData['name'] as String;
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Welcome to DocLinkr,',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '$username',
                          style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,

                        ),
                        SizedBox(height: 30),
                      ],
                    );
                  },
                ),
              ),

      Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: StreamBuilder<DocumentSnapshot>(
          stream: getDoctorData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final userData = snapshot.data?.data() as Map<String, dynamic>;

            return Visibility(
              visible: userData['emergency'] == false || userData['emergency'] == null,
                child: GestureDetector(
                onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Emergency()), // Replace YourNewPage with your actual new page
              );
            },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Do you want to Register as an emergency doctor? Click here to know more.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(width: 40),
                    Icon(
                      Icons.emergency_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ));
          },
        ),
      ),




            ],
          ),

      ),
    );
  }
}