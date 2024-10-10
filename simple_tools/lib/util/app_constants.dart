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
  static const Qrcode = 'QR Code';
  static const Barcode = 'Bar Code';
  static const bmrScreenTitle = 'BMR';
  static const Zakat = 'Zakat Calculator';
  static const ReciepeOrganizer = 'Reciepe Organizer';
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

  static double _height = defaultHeight;
  static int _weight = defaultWeight;
  static int _age = defaultAge;
  static double _result = 0.0;
  static double _bmrresult = 0.0;
  static double _bmiresult = 0.0;

  static String _selectedofgender = 'nope';

  static double get height => _height;
  static set height(double value) => _height = value;

  static int get weight => _weight;
  static set weight(int value) => _weight = value;

  static int get age => _age;
  static set age(int value) => _age = value;

  static double get result => _result;
  static set result(double bmi) => _result = bmi;

  static String get selectedofgender => _selectedofgender;
  static set selectedofgender(String selectedgender) => _selectedofgender = selectedgender;

  static double get bmrresult => _bmrresult;
  static set bmrresult(double bmr) => _bmrresult = bmr;
  static double get bmiresult => _bmiresult;
  static set bmiresult(double bmr) => _bmiresult = bmr;

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


  static const double ZAKAT_PERCENTAGE = 0.025;
  static const String CURRENCY_SYMBOL = 'PKR';

  // API URLs for fetching gold and silver prices
  static const String GOLD_PRICE_API_URL = 'https://api.metals.dev/v1/latest?api_key=OBT7IGJM5TLXQGD7UXQV176D7UXQV&currency=PKR&unit=g';
  static const String SILVER_PRICE_API_URL = 'https://api.metals.dev/v1/latest?api_key=OBT7IGJM5TLXQGD7UXQV176D7UXQV&currency=PKR&unit=g';


}