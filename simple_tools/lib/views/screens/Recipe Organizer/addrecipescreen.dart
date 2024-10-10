import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/Recipe%20Organizer/reciepedetails.dart';

class Addrecipescreen extends StatefulWidget {
  final RecipeDetails? recipeToEdit; // Add parameter for the recipe to edit

  const Addrecipescreen({super.key, this.recipeToEdit}); // Pass recipe to edit in constructor

  @override
  State<Addrecipescreen> createState() => _AddrecipescreenState();
}

List<Map<String, dynamic>> ingredients = [];

class _AddrecipescreenState extends State<Addrecipescreen> {
  final TextEditingController recipename = TextEditingController();
  final TextEditingController recipTime = TextEditingController();
  final TextEditingController _paragraphController = TextEditingController();

  // Single controllers for ingredient name and quantity
  final TextEditingController ingredientNameController = TextEditingController();
  final TextEditingController ingredientQtyController = TextEditingController();

  // Variable to store current editing recipe index
  int? editingRecipeIndex;

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      // If we're in edit mode, load the recipe details into the fields
      RecipeDetails recipe = widget.recipeToEdit!;
      recipename.text = recipe.name;
      recipTime.text = recipe.time;
      _paragraphController.text = recipe.describtion;

      ingredients = List<Map<String, dynamic>>.from(recipe.ingredients);

      // Track the index of the recipe being edited
      _findEditingRecipeIndex(recipe);
    }
  }

  // Function to find the index of the recipe being edited
  void _findEditingRecipeIndex(RecipeDetails recipe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recipesList = prefs.getStringList('recipes');

    if (recipesList != null) {
      for (int i = 0; i < recipesList.length; i++) {
        RecipeDetails existingRecipe = RecipeDetails.fromJson(json.decode(recipesList[i]));
        if (existingRecipe.name == recipe.name) {
          setState(() {
            editingRecipeIndex = i;
          });
          break;
        }
      }
    }
  }

  // Function to load recipes from SharedPreferences
  Future<List<RecipeDetails>> loadRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recipesList = prefs.getStringList('recipes');
    if (recipesList != null) {
      return recipesList.map((recipeString) {
        return RecipeDetails.fromJson(json.decode(recipeString));
      }).toList();
    }
    return [];
  }

  // Function to add or update recipe in SharedPreferences
  void saveRecipe() async {
    // Validate recipe name and at least one ingredient
    if (recipename.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe name is required!")),
      );
      return;
    }
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("At least one ingredient is required!")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Create new RecipeDetails object
    RecipeDetails newRecipe = RecipeDetails(
      name: recipename.text,
      time: recipTime.text,
      ingredients: ingredients,
      describtion: _paragraphController.text,
    );

    List<String>? recipesList = prefs.getStringList('recipes');

    if (recipesList == null) {
      recipesList = [];
    }

    // If editing an existing recipe, replace it in the list
    if (editingRecipeIndex != null) {
      recipesList[editingRecipeIndex!] = json.encode(newRecipe.toJson());
    } else {
      // Add new recipe if not in edit mode
      recipesList.add(json.encode(newRecipe.toJson()));
    }

    try {
      // Store the updated list back to SharedPreferences
      await prefs.setStringList('recipes', recipesList);

      // Clear input fields after saving
      recipename.clear();
      recipTime.clear();
      _paragraphController.clear();
      ingredients.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe saved successfully!")),
      );

      Navigator.pop(context); // Navigate back after saving
    } catch (e) {
      // Handle any error during SharedPreferences save operation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving recipe: $e")),
      );
    }
  }


  @override
  void dispose() {
    recipename.dispose();
    recipTime.dispose();
    _paragraphController.dispose();
    ingredientNameController.dispose();
    ingredientQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let Me Cook"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Name and Time Input
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Recipe Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: recipename,
                      maxLength: 25,
                      decoration: InputDecoration(
                        labelText: "Recipe Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: recipTime,
                      maxLength: 25,
                      decoration: InputDecoration(
                        labelText: "Cooking Time",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Ingredients Section
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ingredients",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ingredients.isEmpty
                        ? const Center(
                      child: Text("No ingredients added yet"),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            ingredients[index]['name']!,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(
                            ingredients[index]['quantity']!,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          onTap: () {
                            // On tap, open a simple dialog to edit the ingredient
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                TextEditingController nameController =
                                TextEditingController(text: ingredients[index]['name']);
                                TextEditingController qtyController =
                                TextEditingController(text: ingredients[index]['quantity']);

                                return AlertDialog(
                                  title: Text('Edit Ingredient'),
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        maxLength: 20,
                                        decoration: InputDecoration(labelText: 'Ingredient Name'),
                                      ),
                                      TextField(
                                        controller: qtyController,
                                        maxLength: 27,
                                        decoration: InputDecoration(labelText: 'Quantity'),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          ingredients[index] = {
                                            'name': nameController.text,
                                            'quantity': qtyController.text,
                                          };
                                        });
                                        Navigator.pop(context); // Close the dialog
                                      },
                                      child: Text('Save'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close the dialog without saving
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onLongPress: () {
                            // On long press, delete the ingredient
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Ingredient'),
                                  content: Text('Are you sure you want to delete this ingredient?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          ingredients.removeAt(index); // Remove ingredient
                                        });
                                        Navigator.pop(context); // Close the dialog
                                      },
                                      child: Text('Yes'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close the dialog without deleting
                                      },
                                      child: Text('No'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ingredientNameController,
                            maxLength: 20,
                            decoration: InputDecoration(
                              labelText: "Ingredient Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: ingredientQtyController,
                            maxLength: 27,
                            decoration: InputDecoration(
                              labelText: "Quantity",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (ingredientNameController.text.isNotEmpty &&
                                ingredientQtyController.text.isNotEmpty) {
                              setState(() {
                                ingredients.add({
                                  'name': ingredientNameController.text,
                                  'quantity': ingredientQtyController.text
                                });
                                ingredientNameController.clear();
                                ingredientQtyController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Description Section
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Recipe Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _paragraphController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Enter Recipe Description",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Save Recipe Button
              Center(
                child: ElevatedButton(
                  onPressed: saveRecipe,
                  child: Text(editingRecipeIndex != null ? "Update Recipe" : "Add Recipe"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
