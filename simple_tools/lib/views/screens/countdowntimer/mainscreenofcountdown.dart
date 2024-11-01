import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'dart:convert';
import 'customtimerscreen.dart';
import 'scrollabletime/scrollabletimerwheel.dart';
import 'timerscreen3.dart';

class TimerScreen1 extends StatefulWidget {
  const TimerScreen1({super.key});

  @override
  TimerScreen1State createState() => TimerScreen1State();
}

class TimerScreen1State extends State<TimerScreen1> {
  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  List<Map<String, dynamic>> customTimers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomTimers();
  }

  void _loadCustomTimers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timersJson = prefs.getString('custom_timers');
    if (timersJson != null) {
      List<dynamic> timersList = json.decode(timersJson);
      setState(() {
        customTimers = List<Map<String, dynamic>>.from(timersList.map((timer) {
          return {
            'name': timer['name'],
            'duration': Duration(seconds: timer['duration']),
            'icon': timer['icon'],
          };
        }));
      });
    }
  }

  void _saveCustomTimers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String timersJson = json.encode(customTimers.map((timer) {
      return {
        'name': timer['name'],
        'duration': timer['duration'].inSeconds,
        'icon': timer['icon'],
      };
    }).toList());
    await prefs.setString('custom_timers', timersJson);
  }

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

  void _deleteCustomTimer(int index) {
    setState(() {
      customTimers.removeAt(index);
    });
    _saveCustomTimers();
  }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Timer Tool',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppConstants.mainColor),
            onPressed: () async {
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
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.35,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConstants.mainColor.withOpacity(
                      0.30), // Increased opacity for darker background
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppConstants.mainColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 80,
                      child: ScrollableTimeWheel(
                        label: 'H',
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
                      width: 80,
                      child: ScrollableTimeWheel(
                        label: 'M',
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
                      width: 80,
                      child: ScrollableTimeWheel(
                        label: 'S',
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: customTimers.isEmpty
                    ? Center(
                        child: Text(
                          'No custom timers saved.',
                          style: TextStyle(
                            color: AppConstants.mainColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: customTimers.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppConstants.mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppConstants.mainColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              leading: Icon(
                                Icons.timer_outlined,
                                size: 32,
                                color: AppConstants.mainColor,
                              ),
                              title: Text(
                                customTimers[index]['name'],
                                style: TextStyle(
                                  color: AppConstants.mainColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                _formatDuration(
                                    customTimers[index]['duration']),
                                style: TextStyle(
                                  color:
                                      AppConstants.mainColor.withOpacity(0.7),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: AppConstants.mainColor,
                                    ),
                                    onPressed: () async {
                                      final editedTimer = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEditTimerScreen(
                                            initialName: customTimers[index]
                                                ['name'],
                                            initialDuration: customTimers[index]
                                                ['duration'],
                                            initialIcon: customTimers[index]
                                                ['icon'],
                                            initialRingtone: customTimers[index]
                                                ['ringtone'],
                                          ),
                                        ),
                                      );
                                      if (editedTimer != null) {
                                        _editCustomTimer(
                                          index,
                                          editedTimer['name'],
                                          editedTimer['duration'],
                                          editedTimer['icon'],
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Timer'),
                                          content: const Text(
                                            'Are you sure you want to delete this timer?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: AppConstants.mainColor,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _deleteCustomTimer(index);
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  selectedHours =
                                      customTimers[index]['duration'].inHours;
                                  selectedMinutes = customTimers[index]
                                              ['duration']
                                          .inMinutes %
                                      60;
                                  selectedSeconds = customTimers[index]
                                              ['duration']
                                          .inSeconds %
                                      60;
                                });
                                navigateToTimerScreen();
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.play_circle_outlined,
                    onPressed: () {
                      if (selectedHours == 0 &&
                          selectedMinutes == 0 &&
                          selectedSeconds == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please set a valid duration.')),
                        );
                      } else {
                        navigateToTimerScreen();
                      }
                    },
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    icon: Icons.add_circle_outline,
                    onPressed: () async {
                      final newTimer = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddEditTimerScreen()),
                      );
                      if (newTimer != null) {
                        _addCustomTimer(
                          newTimer['name'],
                          newTimer['duration'],
                          newTimer['icon'],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.mainColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.mainColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: AppConstants.mainColor),
        onPressed: onPressed,
        padding: const EdgeInsets.all(12),
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
