import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/weightModel.dart';

class weightTrackerService{
  final String? uid;
  final CollectionReference? diseaseCollection;
  weightTrackerService({this.uid, this.diseaseCollection});

  Future<void> updateWeightData(Weight weight) async {
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
        await transaction.update(subCollectionRef, {'weight': weight.toMap()});
      } else {
        // Subcollection doesn't exist, create it
        await transaction.set(subCollectionRef, {'weight': weight.toMap()});
      }
    });
  }

  Future<Weight> getWeightData() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if(docSnapshot.exists){
      return Weight(beforeMeal: docSnapshot.data()!['weight']['beforeMeal'], afterMeal: docSnapshot.data()!['weight']['afterMeal']);
    }
    else{
      return Weight(beforeMeal: 0, afterMeal: 0);
    }
  }


  Future getWeightDataWithDate(String formattedDate) async {

    final docRef = diseaseCollection!.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if (docSnapshot.exists && docSnapshot.data()!['weight'] != null) {
      return Weight(beforeMeal: docSnapshot.data()!['weight']['beforeMeal'], afterMeal: docSnapshot.data()!['weight']['afterMeal']);
    } else {
      return Weight(beforeMeal: 0, afterMeal: 0);
    }
  }


  Future<List<Weight>> getPastWeightData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = diseaseCollection!.doc(uid);
    List<Weight> records = [];

    while (endFormattedDate != startFormattedDate) {
      final docSnapshot = await docRef.collection('records').doc(endFormattedDate).get();

      if (docSnapshot.exists && docSnapshot.data() != null && docSnapshot.data()!['weight'] != null) {
        records.add(Weight(
          beforeMeal: docSnapshot.data()!['weight']['beforeMeal'],
          afterMeal: docSnapshot.data()!['weight']['afterMeal'],
        ));
      }

      // Decrement the date to get data for the previous day
      final currentDate = DateFormat('yyyy-MM-dd').parse(endFormattedDate);
      final previousDate = currentDate.subtract(const Duration(days: 1));
      endFormattedDate = DateFormat('yyyy-MM-dd').format(previousDate);
    }

    return records;
  }

}