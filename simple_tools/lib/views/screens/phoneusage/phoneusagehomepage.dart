import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneUsageHomePage extends StatefulWidget {
  const PhoneUsageHomePage({super.key});

  @override
  State<PhoneUsageHomePage> createState() => _PhoneUsageHomePageState();
}

class _PhoneUsageHomePageState extends State<PhoneUsageHomePage> {
  // Store daily usage stats
  Map<String, int> dailyUsage = {};
  DateTime startTime = DateTime.now();
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  // Load saved usage data from SharedPreferences
  Future<void> _loadUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyUsage = Map<String, int>.from(
        prefs.getKeys().fold<Map<String, int>>({}, (map, key) {
          if (key.startsWith('usage_')) {
            map[key.substring(6)] = prefs.getInt(key) ?? 0;
          }
          return map;
        }),
      );
      isTracking = prefs.getBool('isTracking') ?? false;
      if (isTracking) {
        startTime = DateTime.fromMillisecondsSinceEpoch(
            prefs.getInt('startTime') ?? DateTime.now().millisecondsSinceEpoch);
      }
    });
  }

  // Save usage data to SharedPreferences
  Future<void> _saveUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    dailyUsage.forEach((date, duration) {
      prefs.setInt('usage_$date', duration);
    });
    prefs.setBool('isTracking', isTracking);
    if (isTracking) {
      prefs.setInt('startTime', startTime.millisecondsSinceEpoch);
    }
  }

  void _startTracking() {
    setState(() {
      isTracking = true;
      startTime = DateTime.now();
      _saveUsageData();
    });
  }

  void _stopTracking() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final duration = now.difference(startTime).inMinutes;

    setState(() {
      isTracking = false;
      dailyUsage[today] = (dailyUsage[today] ?? 0) + duration;
      _saveUsageData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Usage Tracker'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Current Session',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (isTracking)
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          final duration = DateTime.now().difference(startTime);
                          return Text(
                            'Time: ${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s',
                            style: Theme.of(context).textTheme.titleLarge,
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isTracking ? _stopTracking : _startTracking,
                      child:
                          Text(isTracking ? 'Stop Tracking' : 'Start Tracking'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dailyUsage.length,
              itemBuilder: (context, index) {
                final date = dailyUsage.keys.elementAt(index);
                final minutes = dailyUsage[date]!;
                return ListTile(
                  title: Text(date),
                  subtitle: Text(
                    '${minutes ~/ 60}h ${minutes % 60}m',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        dailyUsage.remove(date);
                        _saveUsageData();
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
