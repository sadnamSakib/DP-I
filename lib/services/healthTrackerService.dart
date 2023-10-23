import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/UrineModel.dart';
import '../models/bloodPressureModel.dart';
import '../models/foodModel.dart';
import '../models/weightModel.dart';

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
  Future<void> updateWeightData(Weight weight) async {
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
        await transaction.update(subCollectionRef, {'weight': weight.toMap()});
      } else {
        // Subcollection doesn't exist, create it
        await transaction.set(subCollectionRef, {'weight': weight.toMap()});
      }
    });
  }

  Future <void> updateProteinData(double protein) async {
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
        await transaction.update(subCollectionRef, {'protein': protein});
      } else {
        // Subcollection doesn't exist, create it
        await transaction.set(subCollectionRef, {'protein': protein});
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
  Future<void> updateUrineData(Urine urine) async {
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
        await transaction.update(subCollectionRef, {'urine': FieldValue.arrayUnion([urine.toMap()])});
      } else {
        // Subcollection doesn't exist, create it
        await transaction.set(subCollectionRef, {'urine': FieldValue.arrayUnion([urine.toMap()])});
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
  Future<List<Urine>> getUrineData() async {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    final docRef = kidneyDiseaseCollection.doc(uid);

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
  Future<Weight> getWeightData() async {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    final docRef = kidneyDiseaseCollection.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if(docSnapshot.exists){
      return Weight(beforeMeal: docSnapshot.data()!['weight']['beforeMeal'], afterMeal: docSnapshot.data()!['weight']['afterMeal']);
    }
    else{
      return Weight(beforeMeal: 0, afterMeal: 0);
    }
  }

  Future getProteinData() async {
    final now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";

    final docRef = kidneyDiseaseCollection.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if(docSnapshot.exists){
      return docSnapshot.data()!['protein'];
    }
    else{
      return 0;
    }
  }

  // Function to save the selected foods to shared preferences for the current date
  Future<void> saveSelectedFoods(List<Food> foods) async {
    print("Entering saveSelectedFoods"); // This should print

    final prefs = await SharedPreferences.getInstance();
    print("After getting SharedPreferences"); // This should also print

    final currentDate = DateTime.now();
    final key = 'selected_foods_${currentDate.year}-${currentDate.month}-${currentDate.day}';
    final foodsJson = foods.map((food) => food.toJson()).toList();
    await prefs.setString(key, jsonEncode(foodsJson));

    print("Saved selected foods with key: $key"); // This should print
  }

  Future<List<Food>> loadSelectedFoods() async {
    print("Entering loadSelectedFoods"); // This should print

    final prefs = await SharedPreferences.getInstance();
    print("After getting SharedPreferences"); // This should also print

    final currentDate = DateTime.now();
    final key = 'selected_foods_${currentDate.year}-${currentDate.month}-${currentDate.day}';
    final foodsJson = prefs.getString(key);

    if (foodsJson != null) {
      final decoded = jsonDecode(foodsJson) as List;
      final foods = decoded.map((data) => Food.fromJson(data)).toList();
      List<Food> loadedFood = [];
      for (var food in foods) {
        loadedFood.add(food);
      }
      print("Loaded selected foods with key: $key"); // This should print
      return loadedFood;
    } else {
      return [];
    }
  }

  Future<List<BloodPressure>> getBPDataWithDate(String formattedDate) async {


    final docRef = kidneyDiseaseCollection.doc(uid);

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

  Future<int> getWaterDataWithDate(String formattedDate) async {


    final docRef = kidneyDiseaseCollection.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if (docSnapshot.exists && docSnapshot.data()!['water'] != null) {
      return docSnapshot.data()!['water'];
    } else {
      return 0;
    }
  }

  Future<double> getProteinDataWithDate(String formattedDate) async {

    final docRef = kidneyDiseaseCollection.doc(uid);

    final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
    if (docSnapshot.exists && docSnapshot.data()!['protein'] != null) {
      print(docSnapshot.data()!['protein']);
      return docSnapshot.data()!['protein'].toDouble();
    } else {
      print(0);
      return 0;
    }
  }
  Future getWeightDataWithDate(String formattedDate) async {

      final docRef = kidneyDiseaseCollection.doc(uid);

      final docSnapshot = await docRef.collection('records').doc(formattedDate).get();
      if (docSnapshot.exists && docSnapshot.data()!['weight'] != null) {
        return Weight(beforeMeal: docSnapshot.data()!['weight']['beforeMeal'], afterMeal: docSnapshot.data()!['weight']['afterMeal']);
      } else {
        return Weight(beforeMeal: 0, afterMeal: 0);
      }
  }

  Future getUrineDataWithDate(String formattedDate) async {

    final docRef = kidneyDiseaseCollection.doc(uid);

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

  Future<List<BloodPressure>> getPastBpData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = kidneyDiseaseCollection.doc(uid);
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

  Future<List<Urine>> getPastUrineData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = kidneyDiseaseCollection.doc(uid);
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

  Future<List<Weight>> getPastWeightData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = kidneyDiseaseCollection.doc(uid);
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
      final previousDate = currentDate.subtract(Duration(days: 1));
      endFormattedDate = DateFormat('yyyy-MM-dd').format(previousDate);
    }

    return records;
  }

  Future<List<double>> getPastWaterData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = kidneyDiseaseCollection.doc(uid);
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

  Future<List<double>> getPastProteinData(int days) async {
    // Calculate the end date for the past week (today)
    final now = DateTime.now();
    var endFormattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Calculate the start date for the past week (7 days ago)
    final startFormattedDate = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: days)));

    final docRef = kidneyDiseaseCollection.doc(uid);

    print(docRef.toString());
    List<double> records = [];

    while (endFormattedDate != startFormattedDate) {
      final docSnapshot = await docRef.collection('records').doc(endFormattedDate).get();
      if (docSnapshot.exists && docSnapshot.data() != null && docSnapshot.data()!['protein'] != null) {
        records.add(docSnapshot.data()!['protein'].toDouble());
      }

      // Decrement the date to get data for the previous day
      final currentDate = DateFormat('yyyy-MM-dd').parse(endFormattedDate);
      final previousDate = currentDate.subtract(Duration(days: 1));
      endFormattedDate = DateFormat('yyyy-MM-dd').format(previousDate);
    }

    return records;
  }







}

