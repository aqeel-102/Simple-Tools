import 'package:flutter/material.dart';
import 'package:simple_tools/views/screens/barcodegenerator/barcodegeneratormainscreen.dart';
import 'package:simple_tools/views/screens/barcodescanner/barcodescanner.dart';
import 'package:simple_tools/views/screens/chessclock/chesshome.dart';
import 'package:simple_tools/views/screens/home/landingpage.dart';
import 'package:simple_tools/views/screens/passwordmanager/landingforpasswordmanager';
import 'package:simple_tools/views/screens/phoneusageapp/usagehomescreen.dart';
import 'package:simple_tools/views/screens/pomodorotimer/pomodorohome.dart';
import 'package:simple_tools/views/screens/simpackage/prepaid_recharge_calculator.dart';
import 'package:simple_tools/views/screens/sleeptimerecord/sleeptimehomepage.dart';
import 'package:simple_tools/views/screens/timeconverter/timeconverterhome.dart';
import '../../../util/app_constants.dart';
import '../../../util/images.dart';
import '../../custom_widgets/custom_card.dart';
import '../Recipe Organizer/recipe_main_screen.dart';
import '../White Noise Generator/mainscreennoisegenerator.dart';
import '../bmi/bmi.dart';
import '../bmr/bmr.dart';
import '../compass/compassmain.dart';
import '../countdowntimer/mainscreenofcountdown.dart';
import '../deviceinfo/deviceinfohomepage.dart';
import '../kiblafinder/kabbacompassmain.dart';
import '../qrcodescanner/qrcoderhomescreen.dart';
import '../qrgenerator/qrcodegenerator.dart';
import '../studytimer/studytimerhomescreen.dart';
import '../zakatcalculator/zakathome.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // List of card data
  final List<Map<String, dynamic>> cardData = [
    {
      "image": Images.mobileRecharge,
      "title": AppConstants.mobileRecharge,
      "screen": PrepaidRechargeCalculator()
    },
    {"image": Images.bmi, "title": AppConstants.bmi, "screen": Startup()},
    {"image": Images.bmr, "title": AppConstants.bmr, "screen": BMR()},
    {
      "image": Images.timer,
      "title": AppConstants.timer,
      "screen": TimerScreen1()
    },
    {
      "image": Images.compass,
      "title": AppConstants.compassTitle,
      "screen": MyRecentCompass()
    },
    {
      "image": Images.barcode,
      "title": AppConstants.barCode,
      "screen": BarcodeScanner()
    },
    {
      "image": Images.barcode,
      "title": AppConstants.qrCode,
      "screen": QrCoder()
    },
    {
      "image": Images.compass,
      "title": AppConstants.qiblaFinderButton,
      "screen": QiblaCompass()
    },
    {
      "image": Images.compass,
      "title": AppConstants.zakat,
      "screen": ZakatCalculatorApp()
    },
    {
      "image": Images.compass,
      "title": AppConstants.reciepeOrganizer,
      "screen": RecipeMainScreen()
    },
    {
      "image": Images.compass,
      "title": AppConstants.whiteNoiseGenerator,
      "screen": WhiteNoiseGenerator()
    },
    {
      "image": Images.compass,
      "title": AppConstants.passwordManager,
      "screen": LandingForPasswordManager()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.chessClock,
      "screen": ChessHome()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.qrCodeGenerator,
      "screen": QRCodeGenerator()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.barCodeGEnerator,
      "screen": BarcodeGeneratorMainScreen()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.pomodorotimer,
      "screen": PomodoroHome()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.studyTimer,
      "screen": StudyTimerHomeScreen()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.timeConverter,
      "screen": TimeConverterHome()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.deviceDetail,
      "screen": DeviceInfoHomePage()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.sleepTimeTracker,
      "screen": SleepTimeHomePage()
    },
    {
      "image": Images.bmi,
      "title": AppConstants.deviceUsage,
      "screen": UsageHomeScreen()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LandingPage(),
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.mainColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          itemCount: cardData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: CustomCard(
                image: cardData[index]["image"],
                title: cardData[index]["title"],
                nextScreen: cardData[index]["screen"],
              ),
            );
          },
        ),
      ),
    );
  }
}
