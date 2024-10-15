import 'dart:convert';
import 'package:flutter/cupertino.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakathistory.dart';

class ZakatCalculator {
  final double gold;
  final double silver;
  final double cash;
  final double businessAssets;
  final double liabilities;

  ZakatCalculator({
    required this.gold,
    required this.silver,
    required this.cash,
    required this.businessAssets,
    required this.liabilities,
  });



  // Inside the ZakatCalculator class
  Future<void> saveZakatHistory(ZakatHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('zakatHistory');

    List<ZakatHistory> currentHistory = [];
    if (historyString != null) {
      // Decode existing history
      final List<dynamic> historyList = json.decode(historyString);
      currentHistory = historyList.map((item) => ZakatHistory.fromMap(item)).toList();
    }

    // Add the new history entry
    currentHistory.add(history);

    // Save updated history back to SharedPreferences
    final String encodedData = json.encode(currentHistory.map((item) => item.toMap()).toList());
    await prefs.setString('zakatHistory', encodedData);
  }




  // Calculates total assets based on gold, silver, cash, and business assets
  Future<double> get totalAssets async {
    double goldPrice = await getCurrentGoldPrice();
    double silverPrice = await getCurrentSilverPrice();

    var currentAsset = gold + silver + cash + businessAssets;
    var totalAmountOfAsset = currentAsset - liabilities;

    double nisabGoldThreshold = 87.48 * goldPrice; // 7.5 tolas
    double nisabSilverThreshold = 612.15 * silverPrice; // 52.5 tolas

    if (totalAmountOfAsset >= nisabGoldThreshold || totalAmountOfAsset >= nisabSilverThreshold) {
      return totalAmountOfAsset;
    } else {
      return 0;
    }
  }

  // Fetch the current gold price from the API
  Future<double> getCurrentGoldPrice() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.goldPriceApi));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['metals'] != null && data['metals']['gold'] != null) {
          return double.parse(data['metals']['gold']);
        } else {
          throw Exception('Gold price data not available in response');
        }
      } else {
        throw Exception('Failed to load gold price. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching gold price: $e');
      return 60.0; // Default value in case of error
    }
  }

  // Fetch the current silver price from the API
  Future<double> getCurrentSilverPrice() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.silverPriceApi));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['metals'] != null && data['metals']['silver'] != null) {
          return double.parse(data['metals']['silver']);
        } else {
          throw Exception('Silver price data not available in response');
        }
      } else {
        throw Exception('Failed to load silver price. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching silver price: $e');
      return 0.75; // Default value in case of error
    }
  }

  // Calculates Zakat eligibility based on total assets
  Future<String> calculateZakat() async {
    try {
      double returnValue = await totalAssets;

      double goldPrice = await getCurrentGoldPrice();
      double silverPrice = await getCurrentSilverPrice();

      double nisabGoldThreshold = 87.48 * goldPrice; // 7.5 tolas
      double nisabSilverThreshold = 612.15 * silverPrice; // 52.5 tolas

      if (returnValue == 0 || returnValue < nisabSilverThreshold || returnValue < nisabGoldThreshold) {
        return "You are not eligible for zakat";
      } else {
        double zakatAmount = returnValue * 0.025;

        // Save calculation to history
        ZakatHistory newHistory = ZakatHistory(
          date: DateTime.now(),
          zakatAmount: zakatAmount,
          totalAssets: returnValue,
        );

        await saveZakatHistory(newHistory);  // Save history to SharedPreferences

        return "You are eligible for zakat. \nTotal Zakat: $zakatAmount PKR";
      }
    } catch (e) {
      debugPrint('Error calculating zakat: $e');
      return "An error occurred while calculating zakat.";
    }
  }
}





