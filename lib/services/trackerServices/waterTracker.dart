import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class waterTrackerService{
  final String? uid;
  final CollectionReference? diseaseCollection;
  waterTrackerService({this.uid, this.diseaseCollection});

  Future<void> updateWaterData(int water) async {
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
        await transaction.update(subCollectionRef, {'water': water});
      } else {
        // Subcollection doesn't exist, create it
        await transaction.set(subCollectionRef, {'water': water});
      }
    });
  }

  Future getWaterData() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if(docSnapshot.exists){
      return docSnapshot.data()!['water'];
    }
    else{
      return 0;
    }
  }


  Future<int> getWaterDataWithDate(String formattedDate) async {
    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if (docSnapshot.exists && docSnapshot.data()!['water'] != null) {
      return docSnapshot.data()!['water'];
    } else {
      return 0;
    }
  }

  Future<List<double>> getPastWaterData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = diseaseCollection!.doc(uid);
    List<double> records = [];

    while (endFormattedDate != startFormattedDate) {
      final docSnapshot = await docRef.collection('records').doc(endFormattedDate).get();

      if (docSnapshot.exists && docSnapshot.data() != null && docSnapshot.data()!['water'] != null) {
        records.add(docSnapshot.data()!['water'].toDouble());
      }

      // Decrement the date to get data for the previous day
      final currentDate = DateFormat('yyyy-MM-dd').parse(endFormattedDate);
      final previousDate = currentDate.subtract(Duration(days: 1));
      endFormattedDate = DateFormat('yyyy-MM-dd').format(previousDate);
    }
    print(records.toString());
    return records;
  }

}