import 'package:flutter/cupertino.dart';

class RecipeDetails {
  String name;
  String time;
  List<Map<String, dynamic>> ingredients;  // List of Maps with dynamic values
  String describtion;

  RecipeDetails({
    required this.name,
    required this.time,
    required this.ingredients,
    required this.describtion,
  });

  // Convert RecipeDetails to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'ingredients': ingredients,
      'describtion': describtion,
    };
  }

  // Create RecipeDetails from JSON
  static RecipeDetails fromJson(Map<String, dynamic> json) {
    // Using a try-catch to handle potential errors while decoding the ingredients
    List<Map<String, dynamic>> ingredientsList = [];
    if (json['ingredients'] != null) {
      try {
        ingredientsList = List<Map<String, dynamic>>.from(json['ingredients']);
      } catch (e) {
        debugPrint("Error decoding ingredients: $e"); // Print any errors in decoding ingredients
      }
    }

    return RecipeDetails(
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      ingredients: ingredientsList,
      describtion: json['describtion'] ?? '',
    );
  }
}
