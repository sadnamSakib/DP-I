import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/UrineModel.dart';
import '../../models/bloodPressureModel.dart';
import '../../models/foodModel.dart';
import '../../models/weightModel.dart';
import 'waterTracker.dart';
import 'proteinTracker.dart';
import 'weightTracker.dart';
import 'urineTracker.dart';
import 'bpTracker.dart';

class healthTrackerService {
  final String? uid;
  healthTrackerService({this.uid});

  //collection reference
  final CollectionReference kidneyDiseaseCollection = FirebaseFirestore.instance.collection('KidneyDiseases');

  Future<void> updateWaterData(int water) async {
    waterTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).updateWaterData(water);
  }

  Future getWaterData() async {
    return waterTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getWaterData();
  }

  Future<int> getWaterDataWithDate(String formattedDate) async {
    return waterTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getWaterDataWithDate(formattedDate);
  }

  Future<List<double>> getPastWaterData(int days) async {
    return waterTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getPastWaterData(days);
  }

  Future <void> updateProteinData(double protein) async {
    proteinTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).updateProteinData(protein);
  }

  Future getProteinData() async {
    return proteinTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getProteinData();
  }


  Future<List<double>> getPastProteinData(int days) async {
    print('INSIDE getPastProteinData');
    return proteinTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getPastProteinData(days);
  }


  Future<double> getProteinDataWithDate(String formattedDate) async {
    return proteinTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getProteinDataWithDate(formattedDate);
  }

  Future<void> updateWeightData(Weight weight) async {
    weightTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).updateWeightData(weight);
  }

  Future<Weight> getWeightData() async {
    return weightTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getWeightData();
  }


  Future getWeightDataWithDate(String formattedDate) async {
    return weightTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getWeightDataWithDate(formattedDate);
  }


  Future<List<Weight>> getPastWeightData(int days) async {
    return weightTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getPastWeightData(days);
  }

  Future<void> updateUrineData(Urine urine) async {
    urineTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).updateUrineData(urine);
  }

  Future<List<Urine>> getUrineData() async {
    return urineTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getUrineData();
  }

  Future getUrineDataWithDate(String formattedDate) async {
    return urineTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getUrineDataWithDate(formattedDate);
  }

  Future<List<Urine>> getPastUrineData(int days) async {
    return urineTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getPastUrineData(days);
  }

  Future<void> updateBPData(List<BloodPressure>BP) async {
    bpTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).updateBPData(BP);
  }

  Future <List <BloodPressure>> getBPData() async{
    return bpTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getBPData();
  }

  Future<List<BloodPressure>> getBPDataWithDate(String formattedDate) async {
      return bpTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getBPDataWithDate(formattedDate);
  }

  Future<List<BloodPressure>> getPastBpData(int days) async {
    return bpTrackerService(uid: uid, diseaseCollection: kidneyDiseaseCollection).getPastBpData(days);
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













}

