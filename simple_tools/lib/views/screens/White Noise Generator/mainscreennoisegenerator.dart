import 'package:flutter/material.dart';
import '../../../util/soundtracks.dart';
import 'sounddetailscreen.dart'; // Import the screen where the sound plays
import 'noicecustomwidget.dart';

class WhiteNoiseGenerator extends StatefulWidget {
  const WhiteNoiseGenerator({super.key});

  @override
  State<WhiteNoiseGenerator> createState() => _WhiteNoiseGeneratorState();
}

class _WhiteNoiseGeneratorState extends State<WhiteNoiseGenerator> {
  // List of sounds, titles, and corresponding icons
  final List<Map<String, dynamic>> sounds = [
    {"title": "Fan", "sound": Sounds.fan, "icon": Icons.ac_unit},  // Fan icon
    {"title": "Nature", "sound": Sounds.nature, "icon": Icons.nature},  // Nature icon
    {"title": "Rain", "sound": Sounds.rain, "icon": Icons.grain},  // Rain icon
    {"title": "Birds", "sound": Sounds.birds, "icon": Icons.air},  // Birds icon
    {"title": "Ocean", "sound": Sounds.sea, "icon": Icons.waves},  // Ocean icon
    {"title": "Wind", "sound": Sounds.wind, "icon": Icons.wind_power},  // Wind icon
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'White Noise Generator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey[700]!, Colors.blueGrey[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              width: 400,
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.nights_stay_rounded,
                      color: Colors.white70,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'White Noise',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'White noise is a consistent, ambient sound that helps you relax, sleep better, or stay focused.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Using Expanded to make the GridView take up the remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,  // Max width of each grid item
                    crossAxisSpacing: 15,     // Horizontal spacing between tiles
                    mainAxisSpacing: 15,      // Vertical spacing between tiles
                    childAspectRatio: 1.2,    // Width to height ratio
                  ),
                  itemCount: sounds.length,
                  itemBuilder: (context, index) {
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to the next screen when a sound is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SoundDetailScreen(
                                title: sounds[index]["title"]!,
                                sound: sounds[index]["sound"]!,
                              ),
                            ),
                          );
                        },
                        child: NoiseCustom(
                          title: Text(
                            sounds[index]["title"]!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          sound: sounds[index]["sound"]!,
                          icon: sounds[index]["icon"] ?? Icons.music_note,  // Default to a music note icon if null
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
