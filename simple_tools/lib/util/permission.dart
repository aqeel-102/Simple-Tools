import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<void> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
    else{
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Camera Access is not available')),
      );
      Navigator.pop(context as BuildContext);
    }
  }
}