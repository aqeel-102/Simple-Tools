 import 'package:shared_preferences/shared_preferences.dart';

class HistoryHelper {
  static final List<String> _history = [];
  static final List<String> _barcodeHistory = [];

  // Keys for storing the histories in SharedPreferences
  static const String _barcodeHistoryKey = 'barcode_history';
  static const String _qrHistoryKey = 'qrcode_history';

  // Add QR code to history and store it in SharedPreferences
  static Future<void> addToHistory(String qrCode) async {
    _history.add(qrCode);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_qrHistoryKey, _history);
  }

  // Add barcode to history and store it in SharedPreferences
  static Future<void> addBarcodeToHistory(String barcode) async {
    _barcodeHistory.add(barcode);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_barcodeHistoryKey, _barcodeHistory);
  }

  // Get QR code history from SharedPreferences
  static Future<List<String>> getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedHistory = prefs.getStringList(_qrHistoryKey);

    if (savedHistory != null) {
      _history.clear();
      _history.addAll(savedHistory);
    }
    return _history;
  }

  // Get barcode history from SharedPreferences
  static Future<List<String>> getBarcodeHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedHistory = prefs.getStringList(_barcodeHistoryKey);

    if (savedHistory != null) {
      _barcodeHistory.clear();
      _barcodeHistory.addAll(savedHistory);
    }
    return _barcodeHistory;
  }
}
