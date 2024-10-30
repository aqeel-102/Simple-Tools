import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../util/app_constants.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<String> barcodeHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBarcodeHistory();
  }

  Future<void> _loadBarcodeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('barcode_history');
    if (historyJson != null) {
      setState(() {
        barcodeHistory = List<String>.from(json.decode(historyJson));
      });
    }
  }

  Future<void> _saveBarcodeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('barcode_history', json.encode(barcodeHistory));
  }

  void _deleteBarcode(int index) {
    setState(() {
      barcodeHistory.removeAt(index);
    });
    _saveBarcodeHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode History"),
      ),
      body: ListView.builder(
        itemCount: barcodeHistory.length,
        itemBuilder: (context, index) {
          final code = barcodeHistory[index];
          return ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                size: 50.0,
              ),
            ),
            title: Text(code),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(AppConstants
                              .codeCopiedToClipboard)), // Use constant for this
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteBarcode(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
