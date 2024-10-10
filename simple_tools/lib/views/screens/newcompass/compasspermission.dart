import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatelessWidget {
  final Function onPermissionsGranted;

  PermissionPage({required this.onPermissionsGranted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Location Permission Required'),
          ElevatedButton(
            child: Text('Request Permissions'),
            onPressed: () async {
              Permission.locationWhenInUse.request().then((ignored) {
                onPermissionsGranted();
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Open App Settings'),
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
