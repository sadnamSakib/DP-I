import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:design_project_1/services/trackerServices/foodSelection.dart';

import '../../../models/foodModel.dart';
import '../../../services/trackerServices/healthTrackerService.dart';
import 'kidneyDiseaseTracker/kidneyTracker.dart';

class FoodSelectionScreen extends StatefulWidget {
  const FoodSelectionScreen({super.key});

  @override
  State<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<FoodSelectionScreen> {
  final TextEditingController foodInputController = TextEditingController();
  String foodQuery = '';
  Map<String, dynamic>? nutritionData;
  List<String> searchResults = [];
  List<Food> selectedFoods = [];
  double totalProtein = 0;
  @override
  void initState() {
    super.initState();
    loadTotalProtein();

  }
  void loadTotalProtein() async {
    double proteinData = await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).getProteinData();
    setState(() {
      totalProtein = proteinData;
    });
    await healthTrackerService().loadSelectedFoods().then((foods) {
      setState(() {
        selectedFoods = foods as List<Food>;
      });
    });
  }



  void updateTotalProtein() async {
    double protein = 0.0;
    for (var food in selectedFoods) {
      protein += food.protein*food.quantity;
    }
    setState(() {
      totalProtein = protein;
    });
    await healthTrackerService(uid: FirebaseAuth.instance.currentUser!.uid).updateProteinData(totalProtein);
    await healthTrackerService().saveSelectedFoods(selectedFoods);
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue.shade900,
            title: Text('Food Selection'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const KidneyTracker() ));
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              height: 800,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white70, Colors.blue.shade100],
                ),
              ),
              child: Column(
                children: [

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Track today's protein intake", style: TextStyle(fontSize: 20,color: Colors.grey.shade800)),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Protein',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            '${totalProtein.toStringAsFixed(2)} g',
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (query) async {
                        if (query.isNotEmpty) {
                          searchResults = await searchFoods(query: query);
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Search for Foods',

                        suffixIcon: searchResults.isNotEmpty ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            // Clear the search text and results
                            foodInputController.clear();
                            searchResults.clear();
                            setState(() {});
                          },
                        ) : null ,
                      ),
                    ),
                  ),
                  if (searchResults.isNotEmpty)
                    Container(
                      height: 100, // Set a fixed height for the search results container
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(searchResults[index]),
                            // Add a plus icon and functionality to add the item
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                final foodName = searchResults[index];
                                String foodQuery = "1 quantity of ${foodName}";
                                double foodprotein = 0.0;
                                if (foodQuery.isNotEmpty) {
                                  nutritionData = await fetchNutritionData(foodQuery);
                                  if (nutritionData != null) {
                                    foodprotein = nutritionData!['foods'][0]['nf_protein'];
                                  } else {
                                    foodprotein = 0.0;
                                  }
                                  final foodItem =
                                  Food(name: foodName, protein: foodprotein, quantity: 1);
                                  selectedFoods.add(foodItem);
                                }
                                updateTotalProtein();
                              },
                            ),
                          );
                        },
                      ),
                    ),




                  // Display Search Results

                  // Display Selected Foods with Plus and Minus icons
                  if (selectedFoods.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: selectedFoods.map((food) {
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(food.name),
                            subtitle: Text('${food.quantity} serving'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    if(food.quantity==1) {
                                      food.quantity-=1;
                                      setState(() {
                                        selectedFoods.remove(food);
                                        updateTotalProtein();
                                      });
                                    }
                                    else{
                                      food.quantity-=1;
                                      updateTotalProtein();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    food.quantity+=1;
                                    updateTotalProtein();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  // Display Nutrition Data

                ],
              ),
            ),
          ),
        );
  }
}



// Replace fetchNutritionData and searchFoods with actual implementations
