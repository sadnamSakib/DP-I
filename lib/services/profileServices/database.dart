import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference doctorCollection = FirebaseFirestore.instance.collection('doctors');
  final CollectionReference patientCollection = FirebaseFirestore.instance.collection('patients');
  Future updateUserData(String name, String email) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email
    });
  }
  Future updateUserDataWithGoogle(String name, String email,String photoUrl) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'profile' : photoUrl
    });
  }

  Future updateDoctorData(String phone, String chamberAddress,String medicalLicense, String specialization,  List<String> degrees) async {
    DocumentSnapshot user = await userCollection.doc(uid).get();
    String name = user['name'];
    String email = user['email'];
    return await doctorCollection.doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'chamberAddress': chamberAddress,
      'specialization': specialization,
      'degrees': degrees,
      'medicalLicense': medicalLicense
    });
  }

  Future updatePatientData(String gender, String phone, String address, String emergencyPhone,  List<String> preExistingConditions) async {
    DocumentSnapshot user = await userCollection.doc(uid).get();
    String name = user['name'];
    String email = user['email'];
    return await patientCollection.doc(uid).set({
      'gender' : gender,
      'name': name,
      'email': email,
      'phone': phone,
      'emergencyPhone': emergencyPhone,
      'address': address,
      'preExistingConditions': preExistingConditions,
      'emergency': 'none'
    });
  }
  Future setUserRole(String role) async{
    return await userCollection.doc(uid).update({
      'role': role
    });
  }
  //get user doc stream
  Stream<DocumentSnapshot> get userDoc {
    return userCollection.doc(uid).snapshots();
  }

  //get user data stream
  // Stream<QuerySnapshot> get users {
  //   return userCollection.snapshots();
  // }
}