import 'package:cloud_firestore/cloud_firestore.dart';
class diseaseDatabaseService {
  final String? uid;
  diseaseDatabaseService({this.uid});

  //collection reference
  final CollectionReference diseaseCollection = FirebaseFirestore.instance.collection('diseases');

  Future createDiseaseData(String name, String icon) async {
    return await diseaseCollection.doc(uid).set({
      'name': name,
      'icon': icon,

    });
  }
Future deleteDiseaseData() async {
    return await diseaseCollection.doc(uid).delete();
  }
  //get user doc stream
  Stream<DocumentSnapshot> get diseaseDoc {
    return diseaseCollection.doc(uid).snapshots();
  }

  //get user data stream
  // Stream<QuerySnapshot> get users {
  //   return userCollection.snapshots();
  // }
}