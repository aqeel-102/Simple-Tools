import 'package:flutter/material.dart';
import 'dart:async';
import 'package:simple_tools/views/screens/Recipe%20Organizer/reciepedetails.dart';

class MyCustomReciepe extends StatefulWidget {
  final RecipeDetails recipe;

  const MyCustomReciepe({super.key, required this.recipe});

  @override
  _MyCustomReciepeState createState() => _MyCustomReciepeState();
}

class _MyCustomReciepeState extends State<MyCustomReciepe> {
  int currentStep = 0;
  bool isCooking = false;
  bool isPaused = false;
  late Timer _timer;
  int _secondsRemaining = 0;

  void startCooking() {
    if (widget.recipe.steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This recipe has no steps to cook!')),
      );
      return;
    }

    setState(() {
      isCooking = true;
      isPaused = false;
      currentStep = 0;
      _startStepTimer();
    });
  }

  void _startStepTimer() {
    if (currentStep < widget.recipe.steps.length) {
      _secondsRemaining =
          int.tryParse(widget.recipe.steps[currentStep]['time'].toString()) ??
              0;
      _secondsRemaining *= 60; // Convert minutes to seconds
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (!isPaused) {
            if (_secondsRemaining > 0) {
              _secondsRemaining--;
            } else {
              _timer.cancel();
              if (currentStep == widget.recipe.steps.length - 1) {
                // If it's the last step, show meal ready dialog directly
                _showMealReadyDialog();
              } else {
                _showNextStepDialog();
              }
            }
          }
        });
      });
    } else {
      setState(() {
        isCooking = false;
      });
      _showMealReadyDialog();
    }
  }

  void _showNextStepDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Step ${currentStep + 1} Complete'),
          content: Text('Ready for the next step?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentStep++;
                  if (currentStep < widget.recipe.steps.length) {
                    _startStepTimer();
                  } else {
                    isCooking = false;
                    _showMealReadyDialog();
                  }
                });
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showMealReadyDialog() {
    setState(() {
      isCooking = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Meal Ready!'),
          content: Text('Your meal is ready. Enjoy!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _moveToNextStep() {
    if (currentStep < widget.recipe.steps.length - 1) {
      setState(() {
        currentStep++;
        _timer.cancel();
        _startStepTimer();
      });
    } else {
      _timer.cancel();
      _showMealReadyDialog();
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.recipe.name.toUpperCase()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingredients:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.recipe.ingredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = widget.recipe.ingredients[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ingredient['name'],
                                    style: TextStyle(fontSize: 16)),
                                Text(ingredient['quantity'],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.recipe.describtion.isEmpty
                            ? 'Always cook safely'
                            : widget.recipe.describtion,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cooking Steps:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.recipe.steps.length,
                        itemBuilder: (context, index) {
                          final step = widget.recipe.steps[index];
                          return ListTile(
                            title: Text(step['description']),
                            subtitle: Text("${step['time']} minutes"),
                            leading: isCooking && index == currentStep
                                ? Icon(Icons.timer, color: Colors.red)
                                : CircleAvatar(child: Text('${index + 1}')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (!isCooking)
                Center(
                  child: ElevatedButton(
                    onPressed: startCooking,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child:
                          Text('Start Cooking', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                )
              else
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Current Step: ${currentStep + 1}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Time Remaining:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _togglePause,
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(20),
                              ),
                              child: Icon(
                                  isPaused ? Icons.play_arrow : Icons.pause),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Move to Next Step'),
                                      content: Text(
                                          'Are you sure you want to move to the next step?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            _moveToNextStep(); // Move to the next step
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(20),
                              ),
                              child: Icon(Icons.skip_next),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
