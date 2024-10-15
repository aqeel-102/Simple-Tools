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
  static const timer = 'Count Down Timer';
  static const qrCode = 'QR Code';
  static const barCode = 'Bar Code';
  static const bmrScreenTitle = 'BMR';
  static const zakat = 'Zakat Calculator';
  static const reciepeOrganizer = 'Reciepe Organizer';
  static const whiteNoiseGenerator = 'White Noice Generator';
  static const passwordManager = 'Password Manager';
  static const jazzTitle = 'Jazz/Warid';
  static const zongTitle = 'Zong';
  static const telenorTitle = 'Telenor';
  static const ufoneTitle = 'Ufone';
  static const rechargingAmountTitle = 'Recharging\nAmount';
  static const receivingAmountTitle = 'Receiving\nAmount';
  static const amountRechargeMessage = 'Amount You Need To Recharge';
  static const amountReceiveMessage = 'Amount You Will Receive';

  static const mainColor = Color(0xFF448AFF);
  static const secColor = Color(0x55448AFF);
  static const activeColor = Color(0xDD448AFF);
  static const textColor = Colors.white;

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
  static  int hours = 0;
  static int minutes = 0;
  static int seconds = 0;
  static Duration duration = const Duration();
  static Timer? timerx ;
  static bool isRunning = false;
  static bool isPaused = false;


  static const String appName = 'QR Code Reader';
  static const String scanQRCode = 'Scan QR Code';
  static const String scanHistory = 'Scan History';
  static const String uploadImage = 'Scan from Image';
  static const String permissionDenied = 'Permission Denied';
  static const String invalidQRCode = 'Invalid QR Code';
  static const String copy = 'Copy';
  static const String share = 'Share';
  static const String compassTitle = 'Compass';
  static const String qiblaFinderButton = 'Find Qibla Direction';
  static const String compassImage = 'assets/compass.png';
  static const String qiblaArrowImage = 'assets/qibla_arrow.png';
  static const double zakatPercentage = 0.025;
  static const String currancyrate = 'PKR';

  // API URLs for fetching gold and silver prices
  static const String goldPriceApi = 'https://api.metals.dev/v1/latest?api_key=OBT7IGJM5TLXQGD7UXQV176D7UXQV&currency=PKR&unit=g';
  static const String silverPriceApi = 'https://api.metals.dev/v1/latest?api_key=OBT7IGJM5TLXQGD7UXQV176D7UXQV&currency=PKR&unit=g';


}