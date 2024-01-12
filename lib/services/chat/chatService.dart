import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/chat/ServerKey.dart';
import '../../models/Message.dart';

class ChatService extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestEmergency() async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final currentUserData = await _firestore.collection('users').doc(currentUserID).get();
    final String currentUserName = currentUserData['name'] ?? 'CurrentUser';
    final Timestamp timestamp = Timestamp.now();
    // await sendNotificationToAllDoctor();
    // need to handle if the emergency request already exists
    await _firestore.collection('emergencyRequests').doc(currentUserID).set({
      'senderID': currentUserID,
      'senderName': currentUserName,
      'timestamp': timestamp,
    });
  }
  Future<void> sendNotificationToAllDoctor() async {
    NotificationServices notificationServices = NotificationServices();
    print("docotr ashche");
    List<String> doctorTokenList = [];
    await FirebaseFirestore.instance.collection('doctors').get().then((value) {
      print('Number of docs: ${value.docs.length}');
      for (var element in value.docs) {
        doctorTokenList.add(element['deviceToken']);
      }
    });
    print(doctorTokenList);
    notificationServices.getDeviceToken().then((value) async {
      for (var deviceToken in doctorTokenList) {
        var data = {
          'notification': {
            'body': 'Emergency Request from Apurbo',
            'title': 'New Emergency Request!',
          },
          'priority': 'high',
          'to': deviceToken,
          'data': {
            'type': 'emergencyRequest',

          }
        };
        print("notification jao");
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(data),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': key,
            }
        );
      }
    });
  }

  Future<void> dismissEmergencyRequest(String senderID) async {
    final String currentUserID = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // Fetch the names of the sender and current user
    final senderData = await _firestore.collection('users').doc(senderID).get();
    final currentUserData = await _firestore.collection('users').doc(currentUserID).get();

    final String senderName = senderData['name'] ?? 'Sender'; // Replace 'name' with the actual field name in your user document
    final String currentUserName = currentUserData['name'] ?? 'CurrentUser'; // Replace 'name' with the actual field name in your user document

    print("Sender Name: $senderName");
    print("Current User Name: $currentUserName");

    // Update the 'chatrooms' collection with the names
    await _firestore.collection('chatrooms').doc(senderID).set({
      'receiverID': senderID,
      'senderID': currentUserID,
      'senderName': currentUserName,
      'receiverName': senderName,
    });

    // Delete the emergency request
    await _firestore.collection('emergencyRequests').doc(senderID).delete();
  }


 Stream<QuerySnapshot>emergencyRequestList() {
    return _firestore.collection('emergencyRequests').snapshots();
 }

  //send message
  Future<void> sendMessage(String receiverID, String message) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final receiverData = await _firestore.collection('users').doc(receiverID).get();
    final currentUserData = await _firestore.collection('users').doc(currentUserID).get();

    final String receiverName = receiverData['name'] ?? 'Receiver'; // Replace 'name' with the actual field name in your user document
    final String currentUserName = currentUserData['name'] ?? 'CurrentUser';
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderName: currentUserName,
      receiverID: receiverID,
      receiverName: receiverName,
      message: message,
      timestamp: timestamp,

    );

    //construct chatroom id from current user id and receiver id
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatroomID = receiverID;

    //add new message to firestore
    DocumentSnapshot chatroom = await _firestore.collection('chatrooms').doc(chatroomID).get();
    if(!chatroom.exists){
      await _firestore.collection('chatrooms').doc(chatroomID).set({
        'receiverID': receiverID,
        'senderID': currentUserID,

      });
    }
    await _firestore.collection('chatrooms').doc(chatroomID).collection(
        'messages').add(newMessage.toMap());
  }
    //get messages
    Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
      List<String> ids = [userId, otherUserId];
      ids.sort();
      String chatroomID = userId;

      return _firestore.collection('chatrooms').doc(chatroomID).collection('messages').orderBy('timestamp', descending: false).snapshots();
    }

    Stream<DocumentSnapshot> getChatroomData() {
      String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

      return FirebaseFirestore.instance.collection('users').doc(userUID).snapshots();
    }

    getEmergencyDoctor() {
    String userUID = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FirebaseFirestore.instance.collection('emergencyRequests').doc(userUID).snapshots();
  }
  getPreviousEmergencyChats(String receiverID){
    final String currentUserID = _auth.currentUser!.uid;
    print(currentUserID);
    return _firestore.collection('chatrooms').where('senderID', isEqualTo: currentUserID).snapshots();
  }
}