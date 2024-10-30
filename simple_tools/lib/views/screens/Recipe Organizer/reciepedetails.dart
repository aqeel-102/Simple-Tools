// ignore: unused_import
import 'package:flutter/cupertino.dart';

class RecipeDetails {
  final String name;
  final String time;
  final List<Map<String, dynamic>> ingredients;
  final String describtion;
  final List<Map<String, dynamic>> steps;

  RecipeDetails({
    required this.name,
    required this.time,
    required this.ingredients,
    required this.describtion,
    required this.steps,
  });

  // Update fromJson and toJson methods to include steps
  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    return RecipeDetails(
      name: json['name'],
      time: json['time'],
      ingredients: List<Map<String, dynamic>>.from(json['ingredients']),
      describtion: json['describtion'],
      steps: List<Map<String, dynamic>>.from(json['steps']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'ingredients': ingredients,
      'describtion': describtion,
      'steps': steps,
    };
  }
}
