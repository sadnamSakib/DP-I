import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class proteinTrackerService{
  final String? uid;
  final CollectionReference? diseaseCollection;
  proteinTrackerService({this.uid, this.diseaseCollection});

  Future <void> updateProteinData(double protein) async {
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
        await transaction.update(subCollectionRef, {'protein': protein});
      } else {
        // Subcollection doesn't exist, create it
        await transaction.set(subCollectionRef, {'protein': protein});
      }
    });
  }

  Future getProteinData() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if(docSnapshot.exists){
      return docSnapshot.data()!['protein'];
    }
    else{
      return 0;
    }
  }


  Future<List<double>> getPastProteinData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);
    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = diseaseCollection!.doc(uid);

    print(docRef.toString());
    List<double> records = [];

    while (endFormattedDate != startFormattedDate) {
      final docSnapshot = await docRef.collection('records').doc(endFormattedDate).get();
      if (docSnapshot.exists && docSnapshot.data() != null && docSnapshot.data()!['protein'] != null) {
        print('RECORDSSSSSSSS');
        records.add(docSnapshot.data()!['protein'].toDouble());
      }

      // Decrement the date to get data for the previous day
      final currentDate = DateFormat('yyyy-MM-dd').parse(endFormattedDate);
      final previousDate = currentDate.subtract(Duration(days: 1));
      endFormattedDate = DateFormat('yyyy-MM-dd').format(previousDate);
    }

    return records;
  }


  Future<double> getProteinDataWithDate(String formattedDate) async {

    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if (docSnapshot.exists && docSnapshot.data()!['protein'] != null) {
      print(docSnapshot.data()!['protein']);
      return docSnapshot.data()!['protein'].toDouble();
    } else {
      print(0);
      return 0;
    }
  }

}