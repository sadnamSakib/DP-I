import 'package:flutter/material.dart';
import 'package:design_project_1/services/foodSelection.dart';

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
  List<FoodItem> selectedFoods = [];
  double totalProtein = 0;

  void updateTotalProtein() {
    double protein = 0.0;
    for (var food in selectedFoods) {
      protein += food.protein*food.quantity;
    }
    setState(() {
      totalProtein = protein;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                            FoodItem(name: foodName, protein: foodprotein, quantity: 1);
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
    );
  }
}

class FoodItem {
  final String name;
  final double protein;
  int quantity;

  FoodItem({required this.name, required this.protein,required this.quantity});
}

// Replace fetchNutritionData and searchFoods with actual implementations
