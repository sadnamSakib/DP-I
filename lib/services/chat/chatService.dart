import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/Message.dart';

class ChatService extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestEmergency() async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    // need to handle if the emergency request already exists
    await _firestore.collection('emergencyRequests').doc(currentUserID).set({
      'senderID': currentUserID,
      'senderEmail': currentUserEmail,
      'timestamp': timestamp,
    });
  }

  Future<void> dismissEmergencyRequest() async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    // need to handle if the emergency request doesnt exist
    await _firestore.collection('emergencyRequests').doc(currentUserID).delete();
  }



  //send message
  Future<void> sendMessage(String receiverID, String message) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //construct chatroom id from current user id and receiver id
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatroomID = ids.join('_');

    //add new message to firestore
    await _firestore.collection('chatrooms').doc(chatroomID).collection(
        'messages').add(newMessage.toMap());
  }
    //get messages
    Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
      List<String> ids = [userId, otherUserId];
      ids.sort();
      String chatroomID = ids.join('_');

      return _firestore.collection('chatrooms').doc(chatroomID).collection('messages').orderBy('timestamp', descending: false).snapshots();
    }

    Stream<DocumentSnapshot> getChatroomData() {
      String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

      return FirebaseFirestore.instance.collection('users').doc(userUID).snapshots();
    }





}