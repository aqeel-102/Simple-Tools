import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../util/app_constants.dart';
import '../../../util/images.dart';
import '../../custom_widgets/compasscutomwidgets/compasspage.dart';
import '../../custom_widgets/compasscutomwidgets/manualreader.dart';
import '../../custom_widgets/compasscutomwidgets/permissionpage.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  QiblaCompassState createState() => QiblaCompassState();
}

class QiblaCompassState extends State<QiblaCompass> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus(); // Check permission status on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppConstants.appBarTitle), // Use constant for app bar title
      ),
      body: Builder(
        builder: (context) {
          if (_hasPermissions) {
            // If permissions granted, show compass and manual reader
            return Column(
              children: <Widget>[
                Expanded(child: CompassPage(imagePath: Images.kaaba),),
                ManualReaderPage(),
              ],
            );
          } else {
            // Show permission page if permissions not granted
            return PermissionPage(
              onPermissionsGranted: _fetchPermissionStatus,
            );
          }
        },
      ),
    );
  }

  void _fetchPermissionStatus() {
    // Fetch the status of location permissions
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
