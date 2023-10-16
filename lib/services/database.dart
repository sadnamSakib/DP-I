import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String email) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email
    });
  }

  //get user data stream
  // Stream<QuerySnapshot> get users {
  //   return userCollection.snapshots();
  // }
}