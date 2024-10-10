import 'package:flutter/material.dart';
import 'package:simple_tools/views/screens/Recipe%20Organizer/reciepedetails.dart';
import 'custom_recipe.dart'; // Ensure this imports your Recipe model

class MyCustomReciepe extends StatelessWidget {
  final RecipeDetails recipe; // RecipeDetails parameter to receive the selected recipe

  const MyCustomReciepe({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name), // Show recipe name in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Cooking Time
            Text(
              'Cooking Time: ${recipe.time} mins',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Ingredients
            Text(
              'Ingredients:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...recipe.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '• $ingredient',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            )).toList(),
            const SizedBox(height: 20),

            // Description
            Text(
              'Description:',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              recipe.describtion,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
