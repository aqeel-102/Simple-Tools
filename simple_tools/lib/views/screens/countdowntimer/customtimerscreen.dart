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
  String selectedRingtone = AppConstants.defaultRingtone;

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
                  onTap: () =>
                      Navigator.pop(context, AppConstants.defaultRingtone),
                ),
                ListTile(
                  title: const Text(AppConstants.alarmRingtone),
                  onTap: () =>
                      Navigator.pop(context, AppConstants.alarmRingtone),
                ),
                ListTile(
                  title: const Text(AppConstants.notificationRingtone),
                  onTap: () =>
                      Navigator.pop(context, AppConstants.notificationRingtone),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Add Timer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.35,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConstants.mainColor.withOpacity(0.30),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppConstants.mainColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Timer Name',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon:
                        Icon(Icons.timer, color: AppConstants.mainColor),
                    counterText: '',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                  maxLength: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _selectRingtone,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConstants.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppConstants.mainColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected Ringtone: $selectedRingtone',
                        style: TextStyle(
                          color: AppConstants.mainColor,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: AppConstants.mainColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppConstants.mainColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: _saveTimer,
                  child: const Text(
                    'Save Timer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
