import 'package:flutter/material.dart';
import 'package:simple_tools/views/screens/barcodegenerator/barcodegeneratormainscreen.dart';
import 'package:simple_tools/views/screens/barcodescanner/barcodescanner.dart';
import 'package:simple_tools/views/screens/chessclock/chesshome.dart';
import 'package:simple_tools/views/screens/deviceinfo/deviceinfohomepage';
import 'package:simple_tools/views/screens/home/landingpage.dart';
import 'package:simple_tools/views/screens/passwordmanager/landingforpasswordmanager';
import 'package:simple_tools/views/screens/pomodorotimer/pomodorohome';
import 'package:simple_tools/views/screens/simpackage/prepaid_recharge_calculator.dart';
import 'package:simple_tools/views/screens/sleeptimerecord/sleeptimehomepage.dart';
import 'package:simple_tools/views/screens/sleepytimetrack/screentimetrackhomescreen.dart';
import 'package:simple_tools/views/screens/studytimer/studytimerhomescreen';
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
import '../kiblafinder/kabbacompassmain.dart';
import '../qrcodescanner/qrcoderhomescreen.dart';
import '../qrgenerator/qrcodegenerator.dart';
import '../zakatcalculator/zakathome.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CustomCard(
                  image: Images.mobileRecharge,
                  title: AppConstants.mobileRecharge,
                  nextScreen: PrepaidRechargeCalculator(),
                ),
                const SizedBox(height: 20),
                const CustomCard(
                  image: Images.bmi,
                  title: AppConstants.bmi,
                  nextScreen: Startup(),
                ),
                const SizedBox(height: 20),
                const CustomCard(
                  image: Images.bmr,
                  title: AppConstants.bmr,
                  nextScreen: BMR(),
                ),
                const SizedBox(height: 20),
                const CustomCard(
                  image: Images.timer,
                  title: AppConstants.timer,
                  nextScreen: TimerScreen1(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.compassTitle,
                  nextScreen: MyRecentCompass(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.barcode,
                  title: AppConstants.barCode,
                  nextScreen: const BarcodeScanner(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.barcode,
                  title: AppConstants.qrCode,
                  nextScreen: const QrCoder(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.qiblaFinderButton,
                  nextScreen: QiblaCompass(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.zakat,
                  nextScreen: ZakatCalculatorApp(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.reciepeOrganizer,
                  nextScreen: RecipeMainScreen(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.whiteNoiseGenerator,
                  nextScreen: WhiteNoiseGenerator(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.passwordManager,
                  nextScreen: LandingForPasswordManager(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.bmi,
                  title: AppConstants.chessClock,
                  nextScreen: ChessHome(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.bmi,
                  title: AppConstants.qrCodeGenerator,
                  nextScreen: QRCodeGenerator(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.bmi,
                  title: AppConstants.barCodeGEnerator,
                  nextScreen: BarcodeGeneratorMainScreen(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.bmi,
                  title: AppConstants.pomodorotimer,
                  nextScreen: PomodoroHome(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.bmi,
                  title: AppConstants.studyTimer,
                  nextScreen: StudyTimerHomeScreen(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.bmi,
                  title: AppConstants.timeConverter,
                  nextScreen: TimeConverterHome(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.bmi,
                  title: AppConstants.studyTimer,
                  nextScreen: DeviceInfoHomePage(),
                ),
                const SizedBox(height: 20),
                CustomCard(
                  image: Images.bmi,
                  title: AppConstants.deviceUsage,
                  nextScreen: SleepTimeHomePage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
