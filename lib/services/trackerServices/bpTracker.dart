import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/bloodPressureModel.dart';


class bpTrackerService{
  final String? uid;
  final CollectionReference? diseaseCollection;
  bpTrackerService({this.uid, this.diseaseCollection});
  Future<void> updateBPData(List<BloodPressure>BP) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final docRef = diseaseCollection!.doc(uid);

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
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final docRef = diseaseCollection!.doc(uid);

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

  Future<List<BloodPressure>> getBPDataWithDate(String formattedDate) async {


    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if (docSnapshot.exists && docSnapshot.data()!['BP'] != null) {
      List<BloodPressure> records = [];
      for (var record in docSnapshot.data()!['BP']) {
        records.add(BloodPressure(
          systolic: record['systolic'],
          diastolic: record['diastolic'],
          time: record['time'],
        ));
      }
      return records;
    } else {
      return [];
    }
  }



  Future<List<BloodPressure>> getPastBpData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = diseaseCollection!.doc(uid);
    List<BloodPressure> records = [];

    while (endFormattedDate != startFormattedDate) {
      final docSnapshot = await docRef.collection('records').doc(endFormattedDate).get();

      if (docSnapshot.exists && docSnapshot.data() != null && docSnapshot.data()!['BP'] != null) {
        for (var record in docSnapshot.data()!['BP']) {
          records.add(BloodPressure(
            systolic: record['systolic'],
            diastolic: record['diastolic'],
            time: record['time'],
          ));
        }
      }

      // Decrement the date to get data for the previous day
      final currentDate = DateFormat('yyyy-MM-dd').parse(endFormattedDate);
      final previousDate = currentDate.subtract(Duration(days: 1));
      endFormattedDate = DateFormat('yyyy-MM-dd').format(previousDate);
    }

    return records;
  }
}