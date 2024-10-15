import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundDetailScreen extends StatefulWidget {
  final String title;
  final String sound;

  const SoundDetailScreen({super.key,
    required this.title,
    required this.sound,
  });

  @override
  SoundDetailScreenState createState() => SoundDetailScreenState();
}

class SoundDetailScreenState extends State<SoundDetailScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);  // Set the release mode to loop

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.stopped) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  // Play audio logic
  void _playAudio() {
    if (_isPaused) {
      _audioPlayer.resume();
    } else {
      _audioPlayer.play(AssetSource(widget.sound));
    }

    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
  }

  // Pause audio logic
  void _pauseAudio() {
    _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
      _isPaused = true;
    });
  }

  // Stop audio logic
  void _stopAudio() {
    _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[800]!, Colors.blueGrey[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.4),
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Audio Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play/Resume button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isPlaying
                            ? null  // Disable if audio is playing
                            : () {
                          _playAudio();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 12,
                        ),
                        icon: Icon(
                          _isPaused ? Icons.play_arrow : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          _isPaused ? "Resume" : "Play",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    // Pause button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isPlaying
                            ? () {
                          _pauseAudio();
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 12,
                        ),
                        icon: Icon(
                          Icons.pause_circle_filled,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          'Pause',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    // Stop button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _stopAudio();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 12,
                        ),
                        icon: Icon(
                          Icons.stop_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          'Stop',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
