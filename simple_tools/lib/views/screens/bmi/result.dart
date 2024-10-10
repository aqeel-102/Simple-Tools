import 'package:flutter/material.dart';
import '../../../../util/app_constants.dart';

class Result extends StatefulWidget {
  const Result({super.key});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  void calculateBMI() {
    final double heightInMeters =
        AppConstants.height / 100; // convert height from cm to meters
    final double bmi = AppConstants.weight / (heightInMeters * heightInMeters);
    setState(() {
      AppConstants.result = bmi;
    });
  }

  String determineCategory({required double foundedvalue}) {
    if (foundedvalue < 1) {
      return '';
    } else if (foundedvalue < 18.5) {
      return 'Underweight';
    } else if (foundedvalue <= 24.9) {
      return 'Normal Weight';
    } else if (foundedvalue <= 29.9) {
      return 'Overweight';
    } else if (foundedvalue <= 34.9) {
      return 'Obesity Class I';
    } else if (foundedvalue <= 39.9) {
      return 'Obesity Class II';
    } else {
      return 'Obesity Class III';
    }
  }

  String? status;

  @override
  void initState() {
    super.initState();
    
     calculateBMI();
      status  = determineCategory(foundedvalue: AppConstants.result);
    
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 600,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
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
                      "Your Result",
                      style: TextStyle(
                          fontSize: 20,
                          color: AppConstants.textColor,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "BMI: ${AppConstants.result.toStringAsFixed(2)}",
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
      ),
    );
  }
}
