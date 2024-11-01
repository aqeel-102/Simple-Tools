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
    final double height = AppConstants.height;

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
                    "Your BMR Result",
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
                      AppConstants.bmrresult.toStringAsFixed(1),
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
