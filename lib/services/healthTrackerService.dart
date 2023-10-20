import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bloodPressureModel.dart';
import '../models/foodModel.dart';

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



}

