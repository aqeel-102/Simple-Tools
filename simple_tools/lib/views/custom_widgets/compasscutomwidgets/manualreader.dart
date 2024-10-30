import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class ManualReaderPage extends StatefulWidget {
  const ManualReaderPage({super.key});

  @override
  ManualReaderPageState createState() => ManualReaderPageState();
}

class ManualReaderPageState extends State<ManualReaderPage> {
  CompassEvent? _lastRead; // Last compass event read
  DateTime? _lastReadAt; // Timestamp of the last read
  Timer? _timer; // Timer for periodic updates

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the timer when the widget is initialized
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startTimer() {
    // Update the compass reading every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      // Read the compass value
      final CompassEvent tmp = await FlutterCompass.events!.first;
      setState(() {
        _lastRead = tmp;
        _lastReadAt = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Display last read compass event
                  Text(
                    'Direction: ${_lastRead?.heading ?? 'Fetching...'}°',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // Display last read timestamp
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
