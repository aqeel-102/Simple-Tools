import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/countdowntimer/scrollabletime/scrollabletimerwheel.dart';
import '../../../util/app_constants.dart';

class AddEditTimerScreen extends StatefulWidget {
  final String? initialName;
  final Duration? initialDuration;
  final String? initialIcon;
  final String? initialRingtone;

  const AddEditTimerScreen({
    super.key,
    this.initialName,
    this.initialDuration,
    this.initialIcon,
    this.initialRingtone,
  });

  @override
  AddEditTimerScreenState createState() => AddEditTimerScreenState();
}

class AddEditTimerScreenState extends State<AddEditTimerScreen> {
  late final TextEditingController _nameController = TextEditingController();
  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;
  String selectedRingtone = AppConstants.defaultRingtone; // Use constant

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
          title: const Text(AppConstants.selectRingtoneTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  title: const Text(AppConstants.defaultRingtone),
                  onTap: () => Navigator.pop(context, AppConstants.defaultRingtone),
                ),
                ListTile(
                  title: const Text(AppConstants.alarmRingtone),
                  onTap: () => Navigator.pop(context, AppConstants.alarmRingtone),
                ),
                ListTile(
                  title: const Text(AppConstants.notificationRingtone),
                  onTap: () => Navigator.pop(context, AppConstants.notificationRingtone),
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
        const SnackBar(content: Text(AppConstants.timerNameError)),
      );
      return;
    }

    if (selectedHours == 0 && selectedMinutes == 0 && selectedSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.durationError)),
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
    await prefs.setInt('timerCount', timerCount + 1);
    if (!mounted) return;
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'duration': duration,
      'icon': widget.initialIcon ?? AppConstants.timerIcon,
      'ringtone': selectedRingtone,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appBarTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                    color: AppConstants.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 70,
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
                        width: 70,
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
                        width: 70,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: TextField(
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.timer),
                    hintText: 'Timer Name',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black38, // Border color when not focused
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.blue, // Border color when focused
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200], // Background color inside the field
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                  maxLength: 15,
                  controller: _nameController,
                )
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _selectRingtone,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0) ,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey),
                      color: Colors.grey[200],
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
              ),
              const SizedBox(height: 100),
              Container(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: _saveTimer,
                  child: const Text('Save Timer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
