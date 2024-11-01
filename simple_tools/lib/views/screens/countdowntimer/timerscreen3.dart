import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:simple_tools/util/app_constants.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPaused = false;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    final totalDurationInSeconds =
        widget.hours * 3600 + widget.minutes * 60 + widget.seconds;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Timer Running',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircularCountDownTimer(
                  duration: totalDurationInSeconds,
                  initialDuration: 0,
                  controller: _controller,
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  ringColor: const Color.fromARGB(255, 148, 149, 150),
                  fillColor: const Color(0xFF4F69C6),
                  backgroundColor: Colors.white,
                  strokeWidth: 15.0,
                  strokeCap: StrokeCap.round,
                  textStyle: const TextStyle(
                    fontSize: 40.0,
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.w600,
                  ),
                  textFormat: CountdownTextFormat.HH_MM_SS,
                  isReverse: true,
                  isTimerTextShown: true,
                  autoStart: false,
                  onComplete: () async {
                    await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Timer Complete!'),
                        backgroundColor: const Color(0xFF4F69C6),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    onPressed: _isRunning
                        ? null
                        : () {
                            if (_isPaused) {
                              _controller.resume();
                            } else {
                              _controller.start();
                            }
                            setState(() {
                              _isPaused = false;
                              _isRunning = true;
                            });
                          },
                    icon: Icons.play_arrow_rounded,
                    label: 'Start',
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    onPressed: () {
                      _controller.pause();
                      setState(() {
                        _isPaused = true;
                        _isRunning = false;
                      });
                    },
                    icon: Icons.pause_rounded,
                    label: 'Pause',
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    onPressed: () {
                      _controller.restart(duration: totalDurationInSeconds);
                      setState(() {
                        _isPaused = false;
                        _isRunning = false;
                      });
                    },
                    icon: Icons.refresh_rounded,
                    label: 'Reset',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.mainColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          elevation: 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
