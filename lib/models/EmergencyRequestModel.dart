import 'package:cloud_firestore/cloud_firestore.dart';
class EmergencyRequestModel{
  String senderId;
  String senderName;
  Timestamp timestamp;
  EmergencyRequestModel({required this.senderId,required this.senderName,required this.timestamp});
}