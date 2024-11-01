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
    status = determineCategory(foundedvalue: AppConstants.result);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConstants.mainColor,
                    AppConstants.mainColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.mainColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Your Result",
                    style: TextStyle(
                      fontSize: 28,
                      color: AppConstants.textColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      AppConstants.result.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        color: AppConstants.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      status ?? "",
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppConstants.textColor,
                        fontWeight: FontWeight.w600,
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
