import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/bloodPressureModel.dart';

class healthTrackerService {
  final String? uid;
  healthTrackerService({this.uid});

  //collection reference
  final CollectionReference kidneyDiseaseCollection = FirebaseFirestore.instance.collection('KidneyDiseases');

  Future<void> updateWaterData(int water) async {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    final docRef = kidneyDiseaseCollection.doc(uid);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);

      // Check if the subcollection already exists for the given date
      final subCollectionRef = docRef.collection('records').doc(formattedDate);
      final subCollectionSnapshot = await transaction.get(subCollectionRef);

      if (subCollectionSnapshot.exists) {
        // Subcollection exists, update the attribute
        await transaction.update(subCollectionRef, {'water': water});
      } else {
        // Subcollection doesn't exist, create it
        await transaction.set(subCollectionRef, {'water': water});
      }
    });
  }
  Future<void> updateBPData(List<BloodPressure>BP) async {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    final docRef = kidneyDiseaseCollection.doc(uid);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);

      // Check if the subcollection already exists for the given date
      final subCollectionRef = docRef.collection('records').doc(formattedDate);
      final subCollectionSnapshot = await transaction.get(subCollectionRef);

      if (subCollectionSnapshot.exists) {
        // Subcollection exists, update the attribute
        for(BloodPressure b in BP){
          await transaction.update(subCollectionRef, {'BP': FieldValue.arrayUnion([b.toMap()])});
        }
      } else {
        // Subcollection doesn't exist, create it
        for(BloodPressure b in BP){
          await transaction.set(subCollectionRef, {'BP': FieldValue.arrayUnion([b.toMap()])});
        }
      }
    });
  }
Future <List <BloodPressure>> getBPData() async{
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    final docRef = kidneyDiseaseCollection.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if(docSnapshot.exists){
      List<BloodPressure> records = [];
      for(var record in docSnapshot.data()!['BP']){
        records.add(BloodPressure(systolic: record['systolic'], diastolic: record['diastolic'], time: record['time']));
      }
      return records;
    }
    else{
      return [];
    }
  }

  Future getWaterData() async {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    final docRef = kidneyDiseaseCollection.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if(docSnapshot.exists){
      return docSnapshot.data()!['water'];
    }
    else{
      return 0;
    }
  }
  // Future deleteKidneyDiseaseData() async {
  //   return await diseaseCollection.doc(uid).delete();
  // }
  // //get user doc stream
  // Stream<DocumentSnapshot> get diseaseDoc {
  //   return diseaseCollection.doc(uid).snapshots();
  // }

//get user data stream
// Stream<QuerySnapshot> get users {
//   return userCollection.snapshots();
// }
}

