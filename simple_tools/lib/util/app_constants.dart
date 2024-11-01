import 'dart:async';
import 'package:flutter/material.dart';

class AppConstants {
  static const mobileRecharge = 'Mobile Load/Recharge/Balance Calculator';
  static const mobileRechargeScreenTitle = 'Mobile Recharge Calculator';
  static const amountRechargeInputLabel = 'Amount You Recharge(d)';
  static const amountReceiveInputLabel = 'Amount You Will Receive';
  static const bmi = 'Body Mass Index (BMI)';
  static const bmiScreenTitle = 'BMI';
  static const bmr = 'Basal Metabolic Rate (BMR)';
  static const studyTimer = 'Study Timer';
  static const timer = 'Count Down Timer';
  static const qrCode = 'QR Code Scanner';
  static const barCode = 'Bar Code Scanner';
  static const bmrScreenTitle = 'BMR';
  static const zakat = 'Zakat Calculator';
  static const reciepeOrganizer = 'Reciepe Organizer';
  static const whiteNoiseGenerator = 'White Noice Generator';
  static const passwordManager = 'Password Manager';
  static const pomodorotimer = 'Pomodoro Timer';
  static const timeConverter = 'Time Zone Converter';
  static const deviceDetail = 'Deviceware';
  static const deviceUsage = 'Device Usage';
  static const jazzTitle = 'Jazz/Warid';
  static const zongTitle = 'Zong';
  static const telenorTitle = 'Telenor';
  static const ufoneTitle = 'Ufone';
  static const rechargingAmountTitle = 'Recharging\nAmount';
  static const receivingAmountTitle = 'Receiving\nAmount';
  static const amountRechargeMessage = 'Amount You Need To Recharge';
  static const amountReceiveMessage = 'Amount You Will Receive';
  static const Color primaryColor = Colors.blueAccent;
  static const Color majorprimaryColor = Color.fromARGB(255, 44, 108, 210);
  static const Color textColorBlack = Colors.black;
  static const Color secondaryColor = Colors.blueGrey;
  static const Color backgroundColor = Colors.blueGrey;
  static const double buttonHeight = 60.0;
  static const String defaultRingtone = 'Default';
  static const String alarmRingtone = 'Alarm';
  static const String notificationRingtone = 'Notification';
  static const String timerIcon = 'timer_icon';
  static const String timerNameError = 'Please enter a timer name.';
  static const String durationError = 'Please set a valid duration.';
  static const String appBarTitle = 'Add/Edit Timer';
  static const String selectRingtoneTitle = 'Select Ringtone';
  static const String compassAppBarTitle = 'Compass';
  static const String locationPermissionMessage =
      'Location Permission Required';
  static const String readValueButtonText = 'Read Value';
  static const String requestPermissionsButtonText = 'Request Permissions';
  static const String openAppSettingsButtonText = 'Open App Settings';
  static const String deviceNoSensorsMessage = 'Device does not have sensors!';
  static const String errorReadingHeadingMessage = 'Error reading heading: ';
  static const String chessClock = ' Chess Clock';
  static const String barCodeGEnerator = 'Bar-Code Generator ';
  static const String qrCodeGenerator = 'Qr-Code Generator ';
  static const double compassElevation = 4.0;

  static const mainColor = Color(0xFF448AFF);
  static const secColor = Color(0x55448AFF);
  static const activeColor = Color(0xDD448AFF);
  static const textColor = Color.fromARGB(221, 255, 255, 255);

  static var heightController = TextEditingController();
  static var weightController = TextEditingController();
  static var ageController = TextEditingController();

  static var bmrheightController = TextEditingController();
  static var bmrweightController = TextEditingController();
  static var bmrageController = TextEditingController();

  static const int minHeight = 120;
  static const int maxHeight = 280;
  static const double defaultHeight = 180;
  static const int defaultWeight = 60;
  static const int defaultAge = 19;

  static double height = defaultHeight;
  static int weight = defaultWeight;
  static int age = defaultAge;
  static double result = 0.0;
  static double bmrresult = 0.0;
  static double bmiresult = 0.0;
  static String selectedofgender = 'nope';
  static int hours = 0;
  static int minutes = 0;
  static int seconds = 0;
  static Duration duration = const Duration();
  static Timer? timerx;
  static bool isRunning = false;
  static bool isPaused = false;

  static const appName = 'QR Code Reader';
  static const barcodeReaderTitle = 'Barcode Reader';

  // UI Strings
  static const String scanQRCode = 'Scan QR Code';
  static const String scanHistory = 'Scan History';
  static const String uploadImage = 'Scan from Image';
  static const String permissionDenied = 'Permission Denied';
  static const String invalidQRCode = 'Invalid QR Code';
  static const String codeCopiedToClipboard = 'Copied To Clipboard';
  static const String copy = 'Copy';
  static const String share = 'Share';
  static const String compassTitle = 'Compass';
  static const String qiblaFinderButton = 'Find Qibla Direction';
  static const String compassImage = 'assets/compass.png';
  static const String qiblaArrowImage = 'assets/qibla_arrow.png';
  static const double zakatPercentage = 0.025;
  static const String currancyrate = 'PKR';

  // API URLs for fetching gold and silver prices
  static const String baseUrl = 'https://api.metals.dev/v1/latest';
  static const String apiKey = 'X6RJOVFOICTBYBCHANIS945CHANIS';

  // Pomodoro Timer Constants
  static const String pomodoroAppBarTitle = 'Pomodoro Timer';
  static const String workTimeText = 'Work Time';
  static const String breakTimeText = 'Break Time';
  static const String pauseButtonText = 'Pause';
  static const String startButtonText = 'Start';
  static const String resetButtonText = 'Reset';
  static const String completedPomodorosText = 'Completed Pomodoros';
  static const String settingsText = 'Settings';
  static const String workDurationText = 'Work Duration';
  static const String shortBreakDurationText = 'Short Break Duration';
  static const String longBreakDurationText = 'Long Break Duration';
  static const String pomodorosUntilLongBreakText =
      'Pomodoros Until Long Break';
  static const String saveSettingsButtonText = 'Save Settings';
  static const String tasksText = 'Tasks';
  static const String enterTaskHintText = 'Enter a task...';
  static const String addTaskButtonText = 'Add Task';
  static const String minuteText = 'min';

  static const int defaultWorkDuration = 25 * 60;
  static const int defaultShortBreakDuration = 5 * 60;
  static const int defaultLongBreakDuration = 15 * 60;
  static const int defaultPomodorosUntilLongBreak = 4;

  static const String alarmSoundPath =
      'path/to/your/alarm/sound.mp3'; // Replace with actual path

  // New constants for StudyTimerHomeScreen
  static const defaultPadding = 16.0;
  static const smallSpacing = 20.0;
  static const largeSpacing = 20.0;
  static const cardElevation = 4.0;

  // Text styles
  static const TextStyle headlineSmall =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle headlineMedium =
      TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const TextStyle headlineLarge =
      TextStyle(fontSize: 48, fontWeight: FontWeight.bold);
}
