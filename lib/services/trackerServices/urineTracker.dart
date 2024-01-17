import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/UrineModel.dart';

class urineTrackerService{
  final String? uid;
  final CollectionReference? diseaseCollection;
  urineTrackerService({this.uid, this.diseaseCollection});

  Future<void> updateUrineData(Urine urine) async {
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
        await transaction.update(subCollectionRef, {'urine': FieldValue.arrayUnion([urine.toMap()])});
      } else {
        // Subcollection doesn't exist, create it
        await transaction.set(subCollectionRef, {'urine': FieldValue.arrayUnion([urine.toMap()])});
      }
    });
  }

  Future<List<Urine>> getUrineData() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if(docSnapshot.exists){
      List<Urine> records = [];
      for(var record in docSnapshot.data()!['urine']){
        records.add(Urine(volume: record['volume'], color: record['color'], time: record['time']));
      }
      return records;
    }
    else{
      return [];
    }
  }

  Future getUrineDataWithDate(String formattedDate) async {

    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if (docSnapshot.exists && docSnapshot.data()!['urine'] != null) {
      List<Urine> records = [];
      for (var record in docSnapshot.data()!['urine']) {
        records.add(Urine(
          volume: record['volume'],
          color: record['color'],
          time: record['time'],
        ));
      }
      return records;
    } else {
      return [];
    }
  }


  Future<List<Urine>> getPastUrineData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = diseaseCollection!.doc(uid);
    List<Urine> records = [];

    while (endFormattedDate != startFormattedDate) {
      final docSnapshot = await docRef.collection('records').doc(endFormattedDate).get();

      if (docSnapshot.exists && docSnapshot.data() != null && docSnapshot.data()!['urine'] != null) {
        for (var record in docSnapshot.data()!['urine']) {
          records.add(Urine(
            volume: record['volume'],
            color: record['color'],
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