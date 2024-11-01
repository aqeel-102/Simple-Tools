import 'package:flutter/material.dart';
import 'package:simple_tools/views/screens/Recipe%20Organizer/recipe_main_screen.dart';
import 'package:simple_tools/views/screens/White%20Noise%20Generator/mainscreennoisegenerator.dart';
import 'package:simple_tools/views/screens/barcodescanner/barcodescanner.dart';
import 'package:simple_tools/views/screens/bmi/bmi.dart';
import 'package:simple_tools/views/screens/bmr/bmr.dart';
import 'package:simple_tools/views/screens/deviceinfo/deviceinfohomepage';
import 'package:simple_tools/views/screens/passwordmanager/landingforpasswordmanager';
import 'package:simple_tools/views/screens/pomodorotimer/pomodorohome';
import 'package:simple_tools/views/screens/qrgenerator/qrcodegenerator.dart';
import 'package:simple_tools/views/screens/studytimer/studytimerhomescreen';
import 'package:simple_tools/views/screens/timeconverter/timeconverterhome.dart';
import '../util/app_constants.dart';
// Import other screen files as needed

class Tool {
  final String title;
  final IconData icon;
  final Widget nextScreen;

  Tool({
    required this.title,
    required this.icon,
    required this.nextScreen,
  });
}

class ToolsList {
  static final List<Tool> allTools = [
    Tool(
      title: AppConstants.pomodorotimer,
      icon: Icons.timer,
      nextScreen: PomodoroHome(),
    ),
    Tool(
      title: AppConstants.studyTimer,
      icon: Icons.school,
      nextScreen: StudyTimerHomeScreen(),
    ),
    Tool(
      title: AppConstants.reciepeOrganizer,
      icon: Icons.task_alt,
      nextScreen: RecipeMainScreen(),
    ),
    Tool(
      title: AppConstants.timeConverter,
      icon: Icons.access_time,
      nextScreen: TimeConverterHome(),
    ),
    Tool(
      title: AppConstants.passwordManager,
      icon: Icons.lock,
      nextScreen: LandingForPasswordManager(),
    ),
    Tool(
      title: AppConstants.bmi,
      icon: Icons.monitor_weight,
      nextScreen: Startup(),
    ),
    Tool(
      title: AppConstants.bmr,
      icon: Icons.health_and_safety,
      nextScreen: BMR(),
    ),
    Tool(
      title: AppConstants.barCode,
      icon: Icons.qr_code,
      nextScreen: BarcodeScanner(),
    ),
    Tool(
      title: AppConstants.qrCodeGenerator,
      icon: Icons.qr_code_scanner,
      nextScreen: QRCodeGenerator(),
    ),
    Tool(
      title: AppConstants.whiteNoiseGenerator,
      icon: Icons.volume_up,
      nextScreen: WhiteNoiseGenerator(),
    ),
    Tool(
      title: AppConstants.deviceDetail,
      icon: Icons.devices,
      nextScreen: DeviceInfoHomePage(),
    ),
  ];
}
