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
  List<String> qrCodeHistory = [];

  @override
  void initState() {
    super.initState();
    _loadQRCodeHistory();
  }

  Future<void> _loadQRCodeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('qrcode_history');
    if (historyJson != null) {
      setState(() {
        qrCodeHistory = List<String>.from(json.decode(historyJson));
      });
    }
  }

  Future<void> _saveQRCodeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qrcode_history', json.encode(qrCodeHistory));
  }

  void _deleteQRCode(int index) {
    setState(() {
      qrCodeHistory.removeAt(index);
    });
    _saveQRCodeHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code History"),
      ),
      body: ListView.builder(
        itemCount: qrCodeHistory.length,
        itemBuilder: (context, index) {
          final code = qrCodeHistory[index];
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
                  onPressed: () => _deleteQRCode(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
