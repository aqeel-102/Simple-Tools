import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakathistory.dart';

class ZakatCalculator {
  // User inputs
  final double gold;
  final double silver;
  final double cash;
  final double businessAssets;
  final double liabilities;
  final String currency;
  final String unit;

  // Optional cached values for prices
  double? goldPrice;
  double? silverPrice;

  ZakatCalculator({
    required this.currency,
    required this.unit,
    required this.gold,
    required this.silver,
    required this.cash,
    required this.businessAssets,
    required this.liabilities,
  });

  // Helper: Constructs the API URL with the necessary parameters
  String getApiUrl(String currency, String unit) {
    return '${AppConstants.baseUrl}?api_key=${AppConstants.apiKey}&currency=$currency&unit=$unit';
  }

  // Save zakat history to SharedPreferences
  Future<void> saveZakatHistory(ZakatHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyString = prefs.getString('zakatHistory');

      List<ZakatHistory> currentHistory = [];

      if (historyString != null) {
        try {
          // Decode existing history entries
          final List<dynamic> historyList = json.decode(historyString);
          currentHistory =
              historyList.map((item) => ZakatHistory.fromMap(item)).toList();
        } catch (e) {
          debugPrint('Error decoding history: $e');
        }
      }

      // Add the new entry and save it back to SharedPreferences
      currentHistory.add(history);
      final String encodedData =
          json.encode(currentHistory.map((item) => item.toMap()).toList());
      await prefs.setString('zakatHistory', encodedData);

      debugPrint('Zakat history saved successfully!');
    } catch (e) {
      debugPrint('Error saving zakat history: $e');
    }
  }

  // Fetches the current price of gold from the API
  Future<double> getCurrentGoldPrice(String currency, String unit) async {
    try {
      final url = getApiUrl(currency, unit);
      debugPrint('Fetching gold price from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('API Gold Price Data: $data');

        final goldPrice = data['metals']?['gold'];
        if (goldPrice != null) {
          return (goldPrice is double)
              ? goldPrice
              : double.parse(goldPrice.toString());
        } else {
          throw Exception('Gold price data not available in response');
        }
      } else {
        throw Exception(
            'Failed to load gold price. Status code: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('Error fetching gold price: $e');
      throw Exception('Error fetching gold price: $e');
    }
  }

  // Fetches the current price of silver from the API
  Future<double> getCurrentSilverPrice(String currency, String unit) async {
    try {
      final url = getApiUrl(currency, unit);
      debugPrint('Fetching silver price from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('API Silver Price Data: $data');

        final silverPrice = data['metals']?['silver'];
        if (silverPrice != null) {
          return (silverPrice is double)
              ? silverPrice
              : double.parse(silverPrice.toString());
        } else {
          throw Exception('Silver price data not available in response');
        }
      } else {
        throw Exception(
            'Failed to load silver price. Status code: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('No internet connection');
    } catch (e) {
      debugPrint('Error fetching silver price: $e');
      throw Exception('Error fetching silver price: $e');
    }
  }

  // Calculates the total assets and checks if zakat is applicable
  Future<double> get totalAssets async {
    goldPrice ??= await getCurrentGoldPrice(currency, unit);
    silverPrice ??= await getCurrentSilverPrice(currency, unit);

    double calculatedGold = goldPrice! * gold;
    double calculatedSilver = silverPrice! * silver;
    double currentAsset =
        calculatedGold + calculatedSilver + cash + businessAssets;
    double totalAmountOfAsset = currentAsset - liabilities;

    debugPrint('Gold Price: $goldPrice, Silver Price: $silverPrice');
    debugPrint('Total Assets: $totalAmountOfAsset');

    return totalAmountOfAsset >= _nisabGoldThreshold() ||
            totalAmountOfAsset >= _nisabSilverThreshold()
        ? totalAmountOfAsset
        : 0;
  }

  // Private helper: Calculates the gold nisab threshold
  double _nisabGoldThreshold() {
    switch (unit) {
      case 'toz':
        return 7.5 * goldPrice!;
      case 'g':
        return 87.48 * goldPrice!;
      case 'kg':
        return 0.08747859375 * goldPrice!;
      default:
        throw Exception('Invalid unit');
    }
  }

  // Private helper: Calculates the silver nisab threshold
  double _nisabSilverThreshold() {
    switch (unit) {
      case 'toz':
        return 52.5 * silverPrice!;
      case 'g':
        return 612.15 * silverPrice!;
      case 'kg':
        return 0.61235015625 * silverPrice!;
      default:
        throw Exception('Invalid unit');
    }
  }

  // Calculates zakat based on total assets and nisab thresholds
  Future<String> calculateZakat() async {
    try {
      double assets = await totalAssets;

      if (assets <= 0) {
        return "No valid assets found for zakat calculation.";
      }

      if (assets < _nisabGoldThreshold() && assets < _nisabSilverThreshold()) {
        return "You are not eligible for zakat.";
      } else {
        double zakatAmount = assets * 0.025;
        debugPrint("Zakat Amount: $zakatAmount");

        ZakatHistory history = ZakatHistory(
          date: DateTime.now(),
          zakatAmount: zakatAmount,
          totalAssets: assets,
          currency: currency,
        );

        await saveZakatHistory(history);

        return "You are eligible for zakat.\nTotal Zakat: $zakatAmount $currency";
      }
    } on SocketException catch (_) {
      return "No internet connection. Please check your network and try again.";
    } catch (e) {
      debugPrint('Error calculating zakat: $e');
      return "An error occurred while calculating zakat: $e";
    }
  }
}
