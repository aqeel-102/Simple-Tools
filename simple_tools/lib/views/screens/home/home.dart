import 'package:flutter/material.dart';
import 'package:simple_tools/views/screens/simpackage/prepaid_recharge_calculator.dart';
import '../../../util/app_constants.dart';
import '../../../util/images.dart';
import '../../custom_widgets/custom_card.dart';
import '../Recipe Organizer/recipe_main_screen.dart';
import '../White Noise Generator/mainscreennoisegenerator.dart';
import '../barcodereader/barcoderhomescreen.dart';
import '../bmi/bmi.dart';
import '../bmr/bmr.dart';
import '../countdowntimer/mainscreenofcountdown.dart';
import '../newcompass/newcompass.dart';
import '../passwordmanager/passwordmanagerhomepage.dart';
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
      appBar: AppBar(
        backgroundColor: AppConstants.mainColor,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppConstants.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child:  Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 20.0,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const CustomCard(
                  image: Images.mobileRecharge,
                  title: AppConstants.mobileRecharge,
                  nextScreen: PrepaidRechargeCalculator(),
                ),
                const SizedBox(
                  height: 20,
                ),
                const CustomCard(
                  image: Images.bmi,
                  title: AppConstants.bmi,
                  nextScreen: Startup(),
                ),
                const SizedBox(
                  height: 20,
                ),
                const CustomCard(
                  image: Images.bmr,
                  title: AppConstants.bmr,
                  nextScreen: BMR(),
                ),
                const SizedBox(
                  height: 20,
                ),
                const CustomCard(
                  image: Images.timer,
                  title: AppConstants.timer,
                  nextScreen: TimerScreen1(),
                ),
                const SizedBox(
                  height: 20,
                ),
                /* CustomCard(
                  image: Images.qrcode,
                  title: AppConstants.Qrcode,
                  nextScreen: HomeScreen(),
                ), */
                const SizedBox(
                  height: 20,
                ),
                CustomCard(
                  image: Images.barcode,
                  title: AppConstants.barCode,
                  nextScreen: const Barcoder(),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.compassTitle,
                  nextScreen: Mycompass(),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.zakat,
                  nextScreen: ZakatCalculatorApp(),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.reciepeOrganizer,
                  nextScreen: RecipeMainScreen(),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.reciepeOrganizer,
                  nextScreen: WhiteNoiseGenerator(),
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomCard(
                  image: Images.compass,
                  title: AppConstants.reciepeOrganizer,
                  nextScreen: PasswordManagerHomePage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}