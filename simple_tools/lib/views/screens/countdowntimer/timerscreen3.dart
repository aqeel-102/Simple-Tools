import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';

class TimerScreen3 extends StatefulWidget {
  final int hours;
  final int minutes;
  final int seconds;

  const TimerScreen3({
    super.key,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  TimerScreen3State createState() => TimerScreen3State();
}

class TimerScreen3State extends State<TimerScreen3> {
  final CountDownController _controller = CountDownController();
  bool _isPaused = false;
  bool _isRunning = false; // New variable to track the running state

  @override
  Widget build(BuildContext context) {
    // Ensure the total duration is valid
    final totalDurationInSeconds =
        widget.hours * 3600 + widget.minutes * 60 + widget.seconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Running'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularCountDownTimer(
              duration: totalDurationInSeconds,
              initialDuration: 0,
              controller: _controller,
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 2,
              ringColor: Colors.grey[300]!,
              fillColor: Colors.blueAccent,
              backgroundColor: Colors.blue[600],
              strokeWidth: 20.0,
              strokeCap: StrokeCap.round,
              textStyle: const TextStyle(
                fontSize: 33.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textFormat: CountdownTextFormat.HH_MM_SS,
              isReverse: true,
              isTimerTextShown: true,
              autoStart: false,
              onComplete: () {
                // Show a snackbar when the timer completes
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Timer is complete!')),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning // Disable button when timer is running
                      ? null
                      : () {
                          if (_isPaused) {
                            _controller.resume();
                          } else {
                            _controller.start();
                          }
                          setState(() {
                            _isPaused = false;
                            _isRunning = true; // Set running state to true
                          });
                        },
                  child: const Text('Start'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _controller.pause();
                    setState(() {
                      _isPaused = true;
                      _isRunning =
                          false; // Set running state to false when paused
                    });
                  },
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _controller.restart(duration: totalDurationInSeconds);
                    setState(() {
                      _isPaused = false;
                      _isRunning = false; // Reset running state on reset
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
