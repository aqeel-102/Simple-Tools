import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../util/app_constants.dart';
import 'qrcodedetailscreen.dart';
import 'qrcodehistorylist.dart';
import 'dart:convert';

class QrCoder extends StatefulWidget {
  const QrCoder({super.key});

  @override
  State<QrCoder> createState() => _QrCoderState();
}

class _QrCoderState extends State<QrCoder> {
  String? scannedValue;
  bool isScanning = true;
  late MobileScannerController _controller;
  List<String> qrCodeHistory = [];

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _loadqrCodeHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadqrCodeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('qrcode_history');
    if (historyJson != null) {
      setState(() {
        qrCodeHistory = List<String>.from(json.decode(historyJson));
      });
    }
  }

  Future<void> _saveqrCodeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qrcode_history', json.encode(qrCodeHistory));
  }

  Future<void> _addToHistory(String value) async {
    setState(() {
      if (!qrCodeHistory.contains(value)) {
        qrCodeHistory.insert(0, value);
        if (qrCodeHistory.length > 10) {
          qrCodeHistory.removeLast();
        }
      }
    });
    await _saveqrCodeHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('QR Code Scanner'),
        backgroundColor: AppConstants.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: AppConstants.mainColor,
        child: Column(
          children: [
            Expanded(
              child: AiBarcodeScanner(
                hideSheetTitle: true,
                hideSheetDragHandler: true,
                onDetect: (BarcodeCapture capture) {
                  final scannedValue = capture.barcodes.first.rawValue;
                  if (scannedValue != null) {
                    _addToHistory(scannedValue);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BarcodeDetailsScreen(
                          barcode: scannedValue,
                        ),
                      ),
                    );
                  }
                },
                controller: _controller,
                validator: (BarcodeCapture capture) {
                  return capture.barcodes.isNotEmpty;
                },
                errorBuilder: (context, error, child) {
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        error.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                placeholderBuilder: (context, child) {
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Place a QR code in the camera view',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 89, 124, 184),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'View History',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
