import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static const double kabbaLat = 21.4225;
  static const double kabbaLon = 39.8262;

  static Future<void> getQiblaDirection(Function(double, double) onQiblaData) async {
    Position position = await _getLocation();
    double qiblaDirection = calculateQiblaDirection(position.latitude, position.longitude);
    double distanceToQibla = calculateDistance(position.latitude, position.longitude);
    onQiblaData(qiblaDirection, distanceToQibla);
  }

  static Future<Position> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  static double calculateQiblaDirection(double lat, double lon) {
    double deltaLon = (kabbaLon - lon) * (pi / 180);
    double lat1 = lat * (pi / 180);
    double lat2 = kabbaLat * (pi / 180);

    double y = sin(deltaLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);
    double qiblaAngle = atan2(y, x) * (180 / pi);

    return qiblaAngle >= 0 ? qiblaAngle : qiblaAngle + 360;
  }

  static double calculateDistance(double lat, double lon) {
    const double earthRadius = 6371; // Radius in kilometers
    double dLat = (kabbaLat - lat) * (pi / 180);
    double dLon = (kabbaLon - lon) * (pi / 180);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat * (pi / 180)) * cos(kabbaLat * (pi / 180)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}