import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../util/images.dart';

class CompassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data?.heading;

        if (direction == null) {
          return Center(
            child: Text("Device does not have sensors!"),
          );
        }

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1), // Rotate the image based on direction
              child: const Image(
                image: AssetImage(Images.compass),
              ),
            ),
          ),
        );
      },
    );
  }
}
