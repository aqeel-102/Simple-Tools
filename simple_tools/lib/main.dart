import 'package:flutter/material.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/views/screens/home/landingpage.dart';

// Import other screens here...

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Tools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.mainColor,
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
