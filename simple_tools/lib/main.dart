import 'package:flutter/material.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/views/screens/Recipe%20Organizer/recipe_main_screen.dart';
import 'package:simple_tools/views/screens/White%20Noise%20Generator/mainscreennoisegenerator.dart';
import 'package:simple_tools/views/screens/countdowntimer/mainscreenofcountdown.dart';
import 'package:simple_tools/views/screens/home/home.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakathome.dart';

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
      home: WhiteNoiseGenerator(),

      //const Home(title: "Simple Tools"),
    );
  }
}
