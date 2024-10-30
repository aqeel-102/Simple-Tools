import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/Recipe%20Organizer/reciepedetails.dart';
import 'dart:convert'; // Don't forget to import this for json decoding
import 'addrecipescreen.dart';
import 'custom_recipe.dart'; // Assuming this contains your Recipe model

class RecipeMainScreen extends StatefulWidget {
  const RecipeMainScreen({super.key});

  @override
  State<RecipeMainScreen> createState() => _RecipeMainScreenState();
}

class _RecipeMainScreenState extends State<RecipeMainScreen> {
  File? _image; // Variable to hold the selected image file
  late Future<List<RecipeDetails>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = fetchRecipes();
  }

  // Method to pick an image either from the camera or the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Show options to the user: either take a photo or select from gallery
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource
          .gallery, // Change this to ImageSource.camera for taking a photo
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path); // Update the image state
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated')),
      );
    }
  }

  // Function to show the confirmation dialog before picking a new image
  void _showChangeProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Profile Picture'),
          content: Text('Do you want to change your profile picture?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _pickImage(); // Proceed to pick the image
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Fetch saved recipes from SharedPreferences
  Future<List<RecipeDetails>> fetchRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recipesList = prefs.getStringList('recipes');

    if (recipesList == null || recipesList.isEmpty) {
      return []; // Return empty list if no recipes are saved
    }

    // Decode the saved JSON into Recipe objects with error handling
    List<RecipeDetails> recipeDetailsList = [];
    for (String recipeJson in recipesList) {
      try {
        recipeDetailsList.add(RecipeDetails.fromJson(json.decode(recipeJson)));
      } catch (e) {
        debugPrint(
            "Error decoding recipe: $e"); // Handle any errors in decoding
      }
    }

    return recipeDetailsList;
  }

  // Delete a recipe from SharedPreferences
  Future<void> deleteRecipe(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recipesList = prefs.getStringList('recipes');

    if (recipesList != null && recipesList.isNotEmpty) {
      recipesList.removeAt(index); // Remove the recipe at the specified index
      await prefs.setStringList('recipes', recipesList);
      if (!mounted) return; // Save the updated list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe deleted')),
      );
      setState(() {
        _recipesFuture = fetchRecipes(); // Refresh the recipes list
      });
    }
  }

  // Refresh recipes list
  void refreshRecipes() {
    setState(() {
      _recipesFuture = fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Recipe Organizer")),
      ),
      body: Column(
        children: [
          // First part: Profile or banner
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap:
                              _showChangeProfilePictureDialog, // Show dialog on tap
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: _image != null
                                ? FileImage(
                                    _image!) // If image is selected, display it
                                : AssetImage('assets/images/compass.png')
                                    as ImageProvider, // Default image
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(child: Text("My Recipe")),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10), // Optional spacing between sections

          // Second part: List of saved recipes
          Expanded(
            flex: 2,
            child: FutureBuilder<List<RecipeDetails>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Show a loading spinner while fetching recipes
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading recipes')); // Handle error
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No Recipes Found")); // No recipes saved
                } else {
                  // Display list of recipes
                  List<RecipeDetails> recipes = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 items per row
                        crossAxisSpacing: 10, // spacing between columns
                        mainAxisSpacing: 10, // spacing between rows
                        childAspectRatio:
                            2.5, // Adjusted aspect ratio to make boxes smaller
                      ),
                      itemCount: recipes.length, // Ensure item count is set
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Editing Recipe'),
                                  content: Text('What do you want to do?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        // Navigate to the Add Recipe screen for editing
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Addrecipescreen(
                                                    recipeToEdit:
                                                        recipes[index]),
                                          ),
                                        ).then((_) {
                                          refreshRecipes(); // Refresh recipes after editing
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Recipe updated')),
                                          );
                                        });
                                      },
                                      child: Text('Edit'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Delete the recipe
                                        deleteRecipe(index).then((_) {
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyCustomReciepe(
                                        recipe: recipes[index],
                                      )),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.food_bank,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  recipes[index].name,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Time: ${recipes[index].time} mins",
                                  style: const TextStyle(
                                    fontSize: 5,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Addrecipescreen()),
          ).then((_) {
            refreshRecipes(); // Refresh recipes after adding a new one
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('New recipe added')),
            );
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
