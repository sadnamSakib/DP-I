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
  Future setUserRole(String role) async{
    return await userCollection.doc(uid).update({
      'role': role
    });
  }

  //get user data stream
  // Stream<QuerySnapshot> get users {
  //   return userCollection.snapshots();
  // }
}