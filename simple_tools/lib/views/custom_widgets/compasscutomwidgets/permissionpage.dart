// permission_page.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../util/app_constants.dart';

class PermissionPage extends StatelessWidget {
  final Function onPermissionsGranted;

  const PermissionPage({super.key, required this.onPermissionsGranted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(AppConstants.locationPermissionMessage),
          ElevatedButton(
            child: Text(AppConstants.requestPermissionsButtonText),
            onPressed: () async {
              // Request location permissions
              Permission.locationWhenInUse.request().then((ignored) {
                onPermissionsGranted(); // Callback when permissions are granted
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: Text(AppConstants.openAppSettingsButtonText),
            onPressed: () {
              openAppSettings().then((opened) {
                // Handle result if needed
              });
            },
          ),
        ],
      ),
    );
  }
}
