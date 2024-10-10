import 'package:flutter/material.dart';

import '../../../../util/app_constants.dart';

class BmrResult extends StatefulWidget {
  const BmrResult({super.key});

  @override
  State<BmrResult> createState() => _BmrResultState();
}

class _BmrResultState extends State<BmrResult> {
  void calculateBMR() {
    double bmr;

    final double height = AppConstants.height; // height in cm

    if (AppConstants.selectedofgender == 'male') {
      bmr = 10 * AppConstants.weight + 6.25 * height - 5 * AppConstants.age + 5;
    } else {
      bmr =
          10 * AppConstants.weight + 6.25 * height - 5 * AppConstants.age - 161;
    }

    setState(() {
      AppConstants.bmrresult = bmr;
    });
  }

  String determineBMRCategory({required double foundedvalue}) {
    if (foundedvalue <= 1200) {
      return 'Very Low BMR';
    } else if (foundedvalue <= 1600) {
      return 'Low BMR';
    } else if (foundedvalue <= 2000) {
      return 'Average BMR';
    } else if (foundedvalue <= 2400) {
      return 'High BMR';
    } else {
      return 'Very High BMR';
    }
  }

  String? status;
  @override
  void initState() {
    super.initState();
    calculateBMR();
    status = determineBMRCategory(foundedvalue: AppConstants.bmrresult);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: AppConstants.mainColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Your BMR Result",
                    style: TextStyle(
                        fontSize: 20,
                        color: AppConstants.textColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "BMR: ${AppConstants.bmrresult.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 36,
                        color: AppConstants.textColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "Your Health: $status",
                        style: const TextStyle(
                            fontSize: 18,
                            color: AppConstants.textColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
