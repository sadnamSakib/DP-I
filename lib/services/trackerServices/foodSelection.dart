import 'dart:async';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'nutritionixApi.dart' as ntr;
import 'package:http/http.dart' as http;
import 'dart:convert';


Future<dynamic> searchFoods({
  String query = ''
}) async {
  final String apiUrl = 'https://trackapi.nutritionix.com/v2/search/instant';
  const String appId = ntr.appId; // Replace with your Nutritionix App ID
  const String appKey = ntr.apiKey; // Replace with your Nutritionix App Key

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'x-app-id': appId,
    'x-app-key': appKey,
  };

  final response = await http.get(Uri.parse(apiUrl + '?query=$query'), headers: headers);

  if (response.statusCode == 200) {
    dynamic data = json.decode(response.body);
    if (data.containsKey('common')) {
      List<String> foodNames = [];
      for (var item in data['common']) {
        if (item is Map && item.containsKey('food_name')) {
          foodNames.add(item['food_name']);
        }
      }
      return foodNames.sublist(0,5);
    }
  }

  throw Exception('Failed to search for foods');
}



Future<Map<String, dynamic>> fetchNutritionData(String query) async {

  const String apiUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';
  const String appId = ntr.appId; // Replace with your Nutritionix App ID
  const String appKey = ntr.apiKey; // Replace with your Nutritionix App Key

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'x-app-id': appId,
    'x-app-key': appKey,
  };

  final Map<String, String> body = {
    'query': query,
  };

  final response = await http.post(Uri.parse(apiUrl), headers: headers, body: json.encode(body));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to load nutrition data');
  }
}
