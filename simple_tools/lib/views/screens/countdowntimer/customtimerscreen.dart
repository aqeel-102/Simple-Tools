import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:simple_tools/views/screens/countdowntimer/scrollabletime/scrollabletimerwheel.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this

class AddEditTimerScreen extends StatefulWidget {
  final String? initialName;
  final Duration? initialDuration;
  final String? initialIcon;
  final String? initialRingtone; // Added for ringtone

  const AddEditTimerScreen({
    super.key,
    this.initialName,
    this.initialDuration,
    this.initialIcon,
    this.initialRingtone, // Added for ringtone
  });

  @override
  _AddEditTimerScreenState createState() => _AddEditTimerScreenState();
}

class _AddEditTimerScreenState extends State<AddEditTimerScreen> {
  late final TextEditingController _nameController = TextEditingController();
  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;
  String selectedRingtone = "Default"; // Placeholder for selected ringtone

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialDuration != null) {
      selectedHours = widget.initialDuration!.inHours;
      selectedMinutes = widget.initialDuration!.inMinutes % 60;
      selectedSeconds = widget.initialDuration!.inSeconds % 60;
    }
    if (widget.initialRingtone != null) {
      selectedRingtone = widget.initialRingtone!;
    }
  }

  Future<void> _selectRingtone() async {
    final ringtone = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Ringtone'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  title: const Text('Default Ringtone'),
                  onTap: () => Navigator.pop(context, 'Default'),
                ),
                ListTile(
                  title: const Text('Alarm Ringtone'),
                  onTap: () => Navigator.pop(context, 'Alarm'),
                ),
                ListTile(
                  title: const Text('Notification Ringtone'),
                  onTap: () => Navigator.pop(context, 'Notification'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ringtone != null) {
      setState(() {
        selectedRingtone = ringtone;
      });
    }
  }

  Future<void> _saveTimer() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a timer name.'),
        ),
      );
      return;
    }

    if (selectedHours == 0 && selectedMinutes == 0 && selectedSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a valid duration.'),
        ),
      );
      return;
    }

    final duration = Duration(
      hours: selectedHours,
      minutes: selectedMinutes,
      seconds: selectedSeconds,
    );

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final timerCount = prefs.getInt('timerCount') ?? 0;
    await prefs.setString('timer_$timerCount', _nameController.text.trim());
    await prefs.setInt('duration_$timerCount', duration.inSeconds);
    await prefs.setString('ringtone_$timerCount', selectedRingtone);
    await prefs.setInt('timerCount', timerCount + 1); // Update timer count

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'duration': duration,
      'icon': widget.initialIcon ?? 'timer_icon',
      'ringtone': selectedRingtone,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Timer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Timer Name',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                maxLength: 15,
                controller: _nameController,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _selectRingtone,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected Ringtone: $selectedRingtone',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
            Container(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: _saveTimer, // Call the _saveTimer method here
                child: const Text('Save Timer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
