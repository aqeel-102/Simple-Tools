import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../util/app_constants.dart';

class CompassPage extends StatelessWidget {
  final String imagePath; // Image asset path

  const CompassPage({super.key, required this.imagePath}); // Constructor now requires imagePath

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        // Handle errors from the snapshot
        if (snapshot.hasError) {
          return Text('${AppConstants.errorReadingHeadingMessage}${snapshot.error}');
        }

        // Show a loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data?.heading;

        // Check if direction data is available
        if (direction == null) {
          return Center(
            child: Text(AppConstants.deviceNoSensorsMessage),
          );
        }

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: AppConstants.compassElevation,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            // Rotate the compass image based on the direction
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1),
              child: Image(
                image: AssetImage(imagePath), // Use the passed image path
              ),
            ),
          ),
        );
      },
    );
  }
}
