import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/chat/chatService.dart';

import '../../patientInterface/emergencyPortal/chat.dart';

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
        title: Text('Previous Emergency Chats'),
      ),
      body: StreamBuilder(
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

              // Replace with your UI components to display each previous chat
              return ListTile(
                title: Text(chatData['receiverName']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chat(
                        receiverUserEmail: chatData['receiverName'],
                        receiverUserID: chatData['receiverID'],
                      ),
                    ),
                  );
                }
                // Add more details or customize the UI as needed
              );
            }).toList(),
          );
        },
      ),
    );
  }
}