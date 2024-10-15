import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'compassbuilder.dart';
import 'compasspermission.dart';
import 'manualreadercompass.dart';

class Mycompass extends StatefulWidget {
  const Mycompass({super.key});

  @override
  MycompassState createState() => MycompassState();
}

class MycompassState extends State<Mycompass> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Flutter Compass'),
        ),
        body: Builder(
          builder: (context) {
            if (_hasPermissions) {
              return Column(
                children: <Widget>[
                  Expanded(child: CompassPage()),
                  ManualReaderPage(),
                ],
              );
            } else {
              return PermissionPage(
                onPermissionsGranted: _fetchPermissionStatus,
              );
            }
          },
        ),
      );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
