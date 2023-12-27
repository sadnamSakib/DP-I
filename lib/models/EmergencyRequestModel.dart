import 'package:cloud_firestore/cloud_firestore.dart';
class EmergencyRequestModel{
  String senderId;
  String senderEmail;
  Timestamp timestamp;
  EmergencyRequestModel({required this.senderId,required this.senderEmail,required this.timestamp});
}