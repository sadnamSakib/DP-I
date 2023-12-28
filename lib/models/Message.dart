import 'package:cloud_firestore/cloud_firestore.dart';
class Message{
  final String senderID;
  final String senderName;
  final String receiverID;
  final String receiverName;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderName,
    required this.receiverID,
    required this.receiverName,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap(){
    return {
      'senderID': senderID,
      'senderName': senderName,
      'receiverID': receiverID,
      'receiverName': receiverName,
      'message': message,
      'timestamp': timestamp,
    };
  }
}