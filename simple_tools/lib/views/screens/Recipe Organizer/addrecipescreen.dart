import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/Recipe%20Organizer/reciepedetails.dart';

class Addrecipescreen extends StatefulWidget {
  final RecipeDetails? recipeToEdit;

  const Addrecipescreen({super.key, this.recipeToEdit});

  @override
  State<Addrecipescreen> createState() => _AddrecipescreenState();
}

List<Map<String, dynamic>> ingredients = [];
List<Map<String, dynamic>> steps = [];

class _AddrecipescreenState extends State<Addrecipescreen> {
  final TextEditingController recipename = TextEditingController();
  final TextEditingController _paragraphController = TextEditingController();

  final TextEditingController ingredientNameController =
      TextEditingController();
  final TextEditingController ingredientQtyController = TextEditingController();

  int? editingRecipeIndex;

  final TextEditingController stepDescriptionController =
      TextEditingController();
  final TextEditingController stepTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      RecipeDetails recipe = widget.recipeToEdit!;
      recipename.text = recipe.name;
      _paragraphController.text = recipe.describtion;

      ingredients = List<Map<String, dynamic>>.from(recipe.ingredients);
      steps = List<Map<String, dynamic>>.from(recipe.steps);

      _findEditingRecipeIndex(recipe);
    }
  }

  void _findEditingRecipeIndex(RecipeDetails recipe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recipesList = prefs.getStringList('recipes');

    if (recipesList != null) {
      for (int i = 0; i < recipesList.length; i++) {
        RecipeDetails existingRecipe =
            RecipeDetails.fromJson(json.decode(recipesList[i]));
        if (existingRecipe.name == recipe.name) {
          setState(() {
            editingRecipeIndex = i;
          });
          break;
        }
      }
    }
  }

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

  void saveRecipe() async {
    if (recipename.text.isEmpty || ingredients.isEmpty || steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Recipe name, at least one ingredient, and one cooking step are required!")),
      );
      return;
    }

    bool hasValidStep = steps
        .any((step) => step['time'] != null && int.parse(step['time']) > 0);
    if (!hasValidStep) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "At least one cooking step must have a valid timer (greater than 0 minutes)!")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    RecipeDetails newRecipe = RecipeDetails(
      name: recipename.text,
      time: "",
      ingredients: ingredients,
      describtion: _paragraphController.text,
      steps: steps,
    );

    List<String>? recipesList = prefs.getStringList('recipes');

    recipesList ??= [];

    if (editingRecipeIndex != null) {
      recipesList[editingRecipeIndex!] = json.encode(newRecipe.toJson());
    } else {
      recipesList.add(json.encode(newRecipe.toJson()));
    }

    try {
      await prefs.setStringList('recipes', recipesList);
      if (!mounted) return;
      recipename.clear();
      _paragraphController.clear();
      ingredients.clear();
      steps.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe saved successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving recipe: $e")),
      );
    }
  }

  @override
  void dispose() {
    recipename.dispose();
    _paragraphController.dispose();
    ingredientNameController.dispose();
    ingredientQtyController.dispose();
    stepDescriptionController.dispose();
    stepTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let Me Cook"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Recipe Details",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: recipename,
                        maxLength: 25,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]')),
                        ],
                        decoration: InputDecoration(
                          labelText: "Recipe Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ingredients",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ingredients.isEmpty
                          ? const Center(
                              child: Text("No ingredients added yet"),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: ingredients.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: ListTile(
                                    title: Text(
                                      ingredients[index]['name']!,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      ingredients[index]['quantity']!,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            _editIngredient(index);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _deleteIngredient(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ingredientNameController,
                              maxLength: 20,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z\s]')),
                              ],
                              decoration: InputDecoration(
                                labelText: "Ingredient Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: ingredientQtyController,
                              maxLength: 27,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9\s/]')),
                              ],
                              decoration: InputDecoration(
                                labelText: "Quantity",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addIngredient,
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                            ),
                            child: Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cooking Steps",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(steps[index]['description']),
                              subtitle:
                                  Text("Time: ${steps[index]['time']} minutes"),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    steps.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: stepDescriptionController,
                        decoration: InputDecoration(
                          labelText: "Step Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: stepTimeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          labelText: "Step Time (in minutes)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addStep,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                        child: Text("Add Step"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Extra Tips",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _paragraphController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: "Enter Extra Tips",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: saveRecipe,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(editingRecipeIndex != null
                      ? "Update Recipe"
                      : "Add Recipe"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editIngredient(int index) {
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                decoration: InputDecoration(labelText: 'Ingredient Name'),
              ),
              TextField(
                controller: qtyController,
                maxLength: 27,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                ],
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
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteIngredient(int index) {
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
                  ingredients.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _addIngredient() {
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
  }

  void _addStep() {
    if (stepDescriptionController.text.isNotEmpty &&
        stepTimeController.text.isNotEmpty) {
      setState(() {
        steps.add({
          'description': stepDescriptionController.text,
          'time': stepTimeController.text,
        });
        stepDescriptionController.clear();
        stepTimeController.clear();
      });
    }
  }
}
