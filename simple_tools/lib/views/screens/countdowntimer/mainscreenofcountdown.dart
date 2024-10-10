import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'customtimerscreen.dart';
import 'scrollabletime/scrollabletimerwheel.dart';
import 'timerscreen3.dart';

class TimerScreen1 extends StatefulWidget {
  const TimerScreen1({super.key});

  @override
  _TimerScreen1State createState() => _TimerScreen1State();
}

class _TimerScreen1State extends State<TimerScreen1> {
  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  List<Map<String, dynamic>> customTimers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTimers(); // Load timers on screen initialization
  }

  // Load custom timers from SharedPreferences
  void _loadCustomTimers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timersJson = prefs.getString('custom_timers');
    if (timersJson != null) {
      List<dynamic> timersList = json.decode(timersJson);
      setState(() {
        customTimers = List<Map<String, dynamic>>.from(timersList.map((timer) {
          return {
            'name': timer['name'],
            'duration': Duration(seconds: timer['duration']), // Convert back to Duration
            'icon': timer['icon'],
          };
        }));
      });
    }
  }

  // Save custom timers to SharedPreferences
  void _saveCustomTimers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String timersJson = json.encode(customTimers.map((timer) {
      return {
        'name': timer['name'],
        'duration': timer['duration'].inSeconds, // Store as seconds
        'icon': timer['icon'],
      };
    }).toList());
    await prefs.setString('custom_timers', timersJson);
  }

  // Navigate to TimerScreen3 for starting a timer
  void navigateToTimerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen3(
          hours: selectedHours,
          minutes: selectedMinutes,
          seconds: selectedSeconds,
        ),
      ),
    );
  }

  // Add custom timer logic
  void _addCustomTimer(String name, Duration duration, String icon) {
    setState(() {
      customTimers.add({
        'name': name,
        'duration': duration,
        'icon': icon,
      });
    });
    _saveCustomTimers();
  }

  // Delete custom timer
  void _deleteCustomTimer(int index) {
    setState(() {
      customTimers.removeAt(index);
    });
    _saveCustomTimers();
  }

  // Edit custom timer
  void _editCustomTimer(
      int index, String name, Duration duration, String icon) {
    setState(() {
      customTimers[index] = {
        'name': name,
        'duration': duration,
        'icon': icon,
      };
    });
    _saveCustomTimers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Center(child: Text('Timer Tool')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigate to Add/Edit Timer Screen
              final newTimer = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditTimerScreen()),
              );
              if (newTimer != null) {
                _addCustomTimer(
                    newTimer['name'], newTimer['duration'], newTimer['icon']);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: 350,
              height: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 70,
                    child: ScrollableTimeWheel(
                      label: 'h',
                      max: 23,
                      initialValue: selectedHours,
                      onChanged: (hour) {
                        setState(() {
                          selectedHours = hour;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: ScrollableTimeWheel(
                      label: 'm',
                      max: 59,
                      initialValue: selectedMinutes,
                      onChanged: (minute) {
                        setState(() {
                          selectedMinutes = minute;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: ScrollableTimeWheel(
                      label: 's',
                      max: 59,
                      initialValue: selectedSeconds,
                      onChanged: (second) {
                        setState(() {
                          selectedSeconds = second;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: customTimers.isEmpty
                ? Center(
              child: Text(
                'No custom timers saved.',
                style: TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              itemCount: customTimers.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.blueGrey[800],
                  margin: const EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.task_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                    title: Text(
                      customTimers[index]['name'],
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    subtitle: Text(
                      _formatDuration(customTimers[index]['duration']),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            final editedTimer = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditTimerScreen(
                                  initialName: customTimers[index]['name'],
                                  initialDuration: customTimers[index]['duration'],
                                  initialIcon: customTimers[index]['icon'],
                                  initialRingtone: customTimers[index]['ringtone'], // Save ringtone too
                                ),
                              ),
                            );
                            if (editedTimer != null) {
                              _editCustomTimer(index, editedTimer['name'],
                                  editedTimer['duration'], editedTimer['icon']);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Timer'),
                                  content: const Text('Are you sure you want to delete this timer?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteCustomTimer(index);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedHours = customTimers[index]['duration'].inHours;
                        selectedMinutes = customTimers[index]['duration'].inMinutes % 60;
                        selectedSeconds = customTimers[index]['duration'].inSeconds % 60;
                      });
                      navigateToTimerScreen();
                    },
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              if (selectedHours == 0 &&
                  selectedMinutes == 0 &&
                  selectedSeconds == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please set a valid duration.'),
                  ),
                );
              } else {
                navigateToTimerScreen();
              }
            },
            icon: const Icon(Icons.play_circle_outline_rounded, size: 70),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
