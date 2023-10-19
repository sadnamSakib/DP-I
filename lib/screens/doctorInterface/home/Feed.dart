import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/auth.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();

}


Stream<DocumentSnapshot> getUserData() {
  String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

  return FirebaseFirestore.instance.collection('users').doc(userUID).snapshots();
}


class _FeedState extends State<Feed> {

  final AuthService _auth = AuthService();

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
      body: Center(
        child: Column(
          children: [

            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: StreamBuilder<DocumentSnapshot>(
                // You need to define and implement the getUserData() function.
                // It should return a stream of user data.
                stream: getUserData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final userData = snapshot.data?.data() as Map<String,
                      dynamic>;
                  final username = userData['name'] as String;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Welcome to DocLinkr $username.',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Perfect Health Care for you',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
