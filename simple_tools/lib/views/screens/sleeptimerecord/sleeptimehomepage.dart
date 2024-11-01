import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:simple_tools/views/screens/sleeptimerecord/statistics.dart';
import 'package:intl/intl.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class SleepTimeHomePage extends StatefulWidget {
  const SleepTimeHomePage({Key? key}) : super(key: key);

  @override
  _SleepTimeHomePageState createState() => _SleepTimeHomePageState();
}

class _SleepTimeHomePageState extends State<SleepTimeHomePage> {
  late SharedPreferences prefs;
  Map<String, double> sleepData = {};
  Map<String, List<Map<String, dynamic>>> sleepPhases = {};
  DateTime selectedDate = DateTime.now();
  TimeOfDay? bedTime;
  TimeOfDay? wakeTime;
  List<Map<String, dynamic>> alarms = [];
  String selectedRingtone = 'Default';
  bool isTracking = false;
  double sleepGoal = 8.0;
  DateTime? trackingStartTime;
  String? sleepNotes;
  bool enableSleepReminder = false;
  TimeOfDay? sleepReminderTime;
  Duration? currentSleepDuration;
  Timer? sleepTimer;
  Timer? dayCheckTimer;
  String lastProcessedDate = '';
  List<String> sleepTips = [
    'Maintain a consistent sleep schedule',
    'Avoid screens before bedtime',
    'Keep your bedroom cool and dark',
    'Exercise regularly, but not close to bedtime',
  ];

  @override
  void initState() {
    super.initState();
    initializePrefs();
    initBackgroundService();
    _checkAndStartAlarms();
    _startDayCheckTimer();
  }

  @override
  void dispose() {
    sleepTimer?.cancel();
    dayCheckTimer?.cancel();
    super.dispose();
  }

  void _startDayCheckTimer() {
    // Check for day change every minute
    dayCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);

      if (lastProcessedDate != today) {
        // New day started, refresh data
        setState(() {
          lastProcessedDate = today;
          selectedDate = now;
          loadSleepData();
          loadSleepPhases();
        });
      }
    });
  }

  void _checkAndStartAlarms() {
    Future.delayed(const Duration(minutes: 1), () {
      final now = TimeOfDay.now();
      final currentTime = '${now.hour}:${now.minute}';

      for (var alarm in alarms) {
        if (alarm['isEnabled'] && alarm['time'] == currentTime) {
          _startAlarm(alarm);
        }
      }
      _checkAndStartAlarms();
    });
  }

  void _startAlarm(Map<String, dynamic> alarm) async {
    FlutterRingtonePlayer().play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: true,
      volume: 1.0,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alarm'),
          content: const Text('Time to wake up!'),
          actions: [
            TextButton(
              onPressed: () {
                FlutterRingtonePlayer().stop();
                Navigator.of(context).pop();
              },
              child: const Text('Stop Alarm'),
            ),
          ],
        );
      },
    );
  }

  void initBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Future<void> initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    await loadSleepData();
    await loadSleepPhases();
    await loadAlarms();
    sleepGoal = prefs.getDouble('sleep_goal') ?? 8.0;
    enableSleepReminder = prefs.getBool('enable_sleep_reminder') ?? false;
    String? reminderTimeStr = prefs.getString('sleep_reminder_time');
    if (reminderTimeStr != null) {
      List<String> parts = reminderTimeStr.split(':');
      sleepReminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    lastProcessedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> loadSleepPhases() async {
    String? data = prefs.getString('sleep_phases');
    if (data != null) {
      try {
        Map<String, dynamic> decoded = jsonDecode(data);
        setState(() {
          sleepPhases = decoded.map((key, value) => MapEntry(
              key,
              (value as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList()));
        });
      } catch (e) {
        print('Error loading sleep phases: $e');
        sleepPhases = {};
      }
    }
  }

  void saveSleepPhases() {
    try {
      prefs.setString('sleep_phases', jsonEncode(sleepPhases));
    } catch (e) {
      print('Error saving sleep phases: $e');
    }
  }

  Future<void> loadAlarms() async {
    String? alarmsStr = prefs.getString('alarms');
    if (alarmsStr != null) {
      try {
        List<dynamic> decoded = jsonDecode(alarmsStr);
        setState(() {
          alarms = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } catch (e) {
        print('Error loading alarms: $e');
        alarms = [];
      }
    }
  }

  void saveAlarms() {
    try {
      prefs.setString('alarms', jsonEncode(alarms));
    } catch (e) {
      print('Error saving alarms: $e');
    }
  }

  Future<void> loadSleepData() async {
    String? data = prefs.getString('sleep_data');
    if (data != null) {
      try {
        Map<String, dynamic> decoded = jsonDecode(data);
        setState(() {
          sleepData =
              decoded.map((key, value) => MapEntry(key, value.toDouble()));
        });
      } catch (e) {
        print('Error loading sleep data: $e');
        sleepData = {};
      }
    }
  }

  void startSleepTracking() {
    setState(() {
      isTracking = true;
      trackingStartTime = DateTime.now();
      currentSleepDuration = Duration.zero;

      // Start timer to update duration every second
      sleepTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          currentSleepDuration = DateTime.now().difference(trackingStartTime!);
        });
      });
    });
  }

  void stopSleepTracking() {
    if (trackingStartTime != null) {
      DateTime endTime = DateTime.now();
      Duration sleepDuration = endTime.difference(trackingStartTime!);
      double hoursSlept = sleepDuration.inMinutes / 60;

      String dateKey =
          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

      if (!sleepPhases.containsKey(dateKey)) {
        sleepPhases[dateKey] = [];
      }

      sleepPhases[dateKey]!.add({
        'start': trackingStartTime!.toIso8601String(),
        'end': endTime.toIso8601String(),
        'duration': hoursSlept
      });

      sleepData[dateKey] = (sleepData[dateKey] ?? 0) + hoursSlept;

      prefs.setString('sleep_data', jsonEncode(sleepData));
      saveSleepPhases();

      setState(() {
        isTracking = false;
        trackingStartTime = null;
        currentSleepDuration = null;
        sleepTimer?.cancel();
      });
    }
  }

  void addAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        alarms.add({
          'time': '${picked.hour}:${picked.minute}',
          'isEnabled': true,
          'ringtone': selectedRingtone
        });
        saveAlarms(); // Save alarm to SharedPreferences
      });
    }
  }

  void editAlarm(int index) async {
    final parts = alarms[index]['time'].split(':');
    final TimeOfDay initialTime =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        alarms[index]['time'] = '${picked.hour}:${picked.minute}';
        saveAlarms(); // Save updated alarm to SharedPreferences
      });
    }
  }

  void deleteAlarm(int index) {
    setState(() {
      alarms.removeAt(index);
      saveAlarms(); // Save updated alarms list to SharedPreferences after deletion
    });
  }

  void selectRingtone() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Ringtone'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Default'),
            child: const Text('Default'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Chimes'),
            child: const Text('Chimes'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Bell'),
            child: const Text('Bell'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        selectedRingtone = result;
      });
    }
  }

  String getSleepQuality(double hours) {
    if (hours >= 7 && hours <= 9) return 'Optimal';
    if (hours >= 6 && hours < 7) return 'Fair';
    if (hours > 9) return 'Excessive';
    return 'Poor';
  }

  Color getSleepQualityColor(double hours) {
    if (hours >= 7 && hours <= 9) return Colors.green;
    if (hours >= 6 && hours < 7) return Colors.orange;
    if (hours > 9) return Colors.yellow;
    return Colors.red;
  }

  double getWeeklyAverage() {
    double total = 0;
    int count = 0;
    DateTime weekStart =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    for (int i = 0; i < 7; i++) {
      DateTime day = weekStart.add(Duration(days: i));
      String key = "${day.year}-${day.month}-${day.day}";
      if (sleepData.containsKey(key)) {
        total += sleepData[key]!;
        count++;
      }
    }

    return count > 0 ? total / count : 0;
  }

  void previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
  }

  void nextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
    });
  }

  void setSleepReminder() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: sleepReminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        sleepReminderTime = picked;
        enableSleepReminder = true;
        prefs.setBool('enable_sleep_reminder', true);
        prefs.setString(
            'sleep_reminder_time', '${picked.hour}:${picked.minute}');
      });
    }
  }

  void addSleepNotes() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Notes'),
        content: TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'How was your sleep? Any disturbances?',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: sleepNotes),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final textField =
                  context.findAncestorWidgetOfExactType<TextField>();
              Navigator.pop(context, textField?.controller?.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        sleepNotes = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateKey =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
    double todaySleep = sleepData[dateKey] ?? 0;
    List<Map<String, dynamic>> todayPhases = sleepPhases[dateKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Sleep Timer Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          isTracking ? 'Sleep in Progress' : 'Start Tracking',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        if (isTracking && currentSleepDuration != null)
                          Text(
                            '${currentSleepDuration!.inHours}:${(currentSleepDuration!.inMinutes % 60).toString().padLeft(2, '0')}:${(currentSleepDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: isTracking ? null : startSleepTracking,
                              icon: const Icon(Icons.nightlight_round),
                              label: const Text('Start'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: !isTracking ? null : stopSleepTracking,
                              icon: const Icon(Icons.wb_sunny),
                              label: const Text('Stop'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sleep Phases Card
                if (todayPhases.isNotEmpty)
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Sleep Phases',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: todayPhases.length,
                            itemBuilder: (context, index) {
                              final phase = todayPhases[index];
                              final start = DateTime.parse(phase['start']);
                              final end = DateTime.parse(phase['end']);
                              return ListTile(
                                leading: const Icon(Icons.bedtime),
                                title: Text(
                                  '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}',
                                ),
                                subtitle: Text(
                                  'Duration: ${phase['duration'].toStringAsFixed(1)}h',
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Alarms Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Alarms',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: selectRingtone,
                                  icon: const Icon(Icons.music_note),
                                  tooltip: 'Select Ringtone',
                                ),
                                IconButton(
                                  onPressed: addAlarm,
                                  icon: const Icon(Icons.add_alarm),
                                  tooltip: 'Add Alarm',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: alarms.length,
                          itemBuilder: (context, index) {
                            final alarm = alarms[index];
                            return ListTile(
                              leading: const Icon(Icons.alarm),
                              title: Text(alarm['time']),
                              subtitle: Text('Ringtone: ${alarm['ringtone']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: alarm['isEnabled'],
                                    onChanged: (value) {
                                      setState(() {
                                        alarm['isEnabled'] = value;
                                        saveAlarms(); // Save alarm state to SharedPreferences
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => editAlarm(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => deleteAlarm(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Stats Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Sleep',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${todaySleep.toStringAsFixed(1)}h',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  getSleepQuality(todaySleep),
                                  style: TextStyle(
                                    color: getSleepQualityColor(todaySleep),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: addSleepNotes,
                              icon: const Icon(Icons.note_add),
                              tooltip: 'Add sleep notes',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sleep Tips Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sleep Tips',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        ...sleepTips.map((tip) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.tips_and_updates, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(tip)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Actions Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SleepStatisticsScreen(
                              sleepData: sleepData,
                              sleepPhases: sleepPhases,
                              selectedDate: selectedDate,
                              getSleepQuality: getSleepQuality,
                              getSleepQualityColor: getSleepQualityColor,
                              getWeeklyAverage: getWeeklyAverage,
                              previousDay: previousDay,
                              nextDay: nextDay,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.analytics),
                        label: const Text('Statistics'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
