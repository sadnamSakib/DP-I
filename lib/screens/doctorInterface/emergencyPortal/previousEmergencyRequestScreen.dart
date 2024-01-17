import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/chatServices/chatService.dart';

import '../../doctorInterface/emergencyPortal/chat.dart';

class PreviousEmergencyRequestList extends StatefulWidget {
  const PreviousEmergencyRequestList({Key? key}) : super(key: key);

  @override
  _PreviousEmergencyRequestListState createState() => _PreviousEmergencyRequestListState();
}

class _PreviousEmergencyRequestListState extends State<PreviousEmergencyRequestList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade900,
        title: Text('Previous Emergency Chats'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white70, Colors.pink.shade50],
          ),
        ),
        child: StreamBuilder(
          stream: _chatService.getPreviousEmergencyChats(currentUserID),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading previous chats'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No previous chats available.'),
              );
            }

            return ListView(

              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String?, dynamic> chatData = document.data() as Map<
                    String?,
                    dynamic>;

                return ListTile(
                    contentPadding: EdgeInsets.all(10.0),
                    tileColor: Colors.teal[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(color: Colors.teal.shade50),
                    ),
                  title: Text(chatData['receiverName'],
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          receiverUserID: chatData['receiverID'],
                        ),
                      ),
                    );
                  }
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}