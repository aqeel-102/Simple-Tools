import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorHelper {
  static StreamSubscription? _compassSubscription;
  static String accuracyMessage = "Calibrating...";

  static void getCompassHeading(Function(double) onHeadingChange) {
    // Call the function to get the stream
    _compassSubscription = magnetometerEventStream().listen((event) {
      // Compute heading from sensor data
      double heading = calculateHeading(event.x, event.y);
      onHeadingChange(heading);
      // Update accuracy status based on sensor data strength
      accuracyMessage = (event.x.abs() > 0.1 && event.y.abs() > 0.1)
          ? "Good Accuracy"
          : "Poor Accuracy - Recalibrate";
    });
  }

  static double calculateHeading(double x, double y) {
    double heading = (180 / pi) * (x == 0 ? (y > 0 ? pi / 2 : -pi / 2) : atan2(y, x));
    return heading >= 0 ? heading : heading + 360;
  }

  static void dispose() {
    _compassSubscription?.cancel();
  }
}
