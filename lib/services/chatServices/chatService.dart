import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_project_1/services/notificationServices/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/chatServices/ServerKey.dart';
import '../../models/Message.dart';
import 'package:design_project_1/services/authServices/auth.dart';
class ChatService extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestEmergency(String initialMessage) async {
    //get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final currentUserData = await _firestore.collection('users').doc(currentUserID).get();
    final String currentUserName = currentUserData['name'] ?? 'CurrentUser';

    final Timestamp timestamp = Timestamp.now();


    // need to handle if the emergency request already exists
    await _firestore.collection('emergencyRequests').doc(currentUserID).set({
      'senderID': currentUserID,
      'senderName': currentUserName,
      'timestamp': timestamp,
      'initialMessage' : initialMessage,
    });
    await _firestore.collection('patients').doc(currentUserID).update({
      'emergency': 'pending',
    });
    await sendNotificationToAllDoctor();
    notifyListeners();
  }
  Future<void> sendNotificationToAllDoctor() async {
    print("docotr ashche");
    List<String> doctorTokenList = [];
    await FirebaseFirestore.instance.collection('doctors').get().then((value) {
      print('Number of docs: ${value.docs.length}');
      for (var element in value.docs) {
        if(element.data().containsKey('deviceToken') && element.data().containsKey('emergency') && element['emergency'] == true ){
          doctorTokenList.add(element['deviceToken'].toString());
        }
      }
    });
    print(doctorTokenList);
    for(var doctorToken in doctorTokenList){
      await sendNotificationToDoctor(doctorToken, "Emergency Request", "A new emergency request has been made");
    }
  }
  Future<void> sendNotificationToDoctor(String doctorToken, String body, String title) async {
    try{
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': key.toString(),
        },
        body: jsonEncode(

          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
              'type': 'emergency',
            },
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'android_channel_id': '4',
            },

            'to': doctorToken.toString(),
          },
        ),
      );
        }
        catch(e){
      if(kDebugMode) {
        print("error in sending notification");
      }
    }
  }

  Future<void> dismissEmergencyRequest(String senderID,String initialMessage) async {
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
    if(initialMessage.isNotEmpty)
      {
        await _firestore.collection('chatrooms').doc(senderID).collection('messages').add({
          'senderID': senderID,
          'senderName': senderName,
          'receiverID': currentUserID,
          'receiverName': currentUserName,
          'message': initialMessage,
          'timestamp': timestamp,
        });
      }
    await _firestore.collection('emergencyRequests').doc(senderID).delete();

    await _firestore.collection('patients').doc(senderID).update({
      'emergency': 'accepted',
    });
    notifyListeners();
  }

  Future<void> dismissEmergencyChat() async {
    final String currentUserID = _auth.currentUser!.uid;
    await _firestore.collection('patients').doc(currentUserID).update({
      'emergency': 'none',
    });

    notifyListeners();
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