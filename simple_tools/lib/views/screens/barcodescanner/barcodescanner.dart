import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/barcodescanner/barcodedetail.dart';
import 'package:simple_tools/views/screens/barcodescanner/barcodescannerhistory.dart';
import '../../../util/app_constants.dart';
import 'dart:convert';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  String? scannedValue;
  bool isScanning = true;
  late MobileScannerController _controller;
  List<String> barcodeHistory = [];

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    _loadBarcodeHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  Future<void> _addToHistory(String value) async {
    setState(() {
      if (!barcodeHistory.contains(value)) {
        barcodeHistory.insert(0, value);
        if (barcodeHistory.length > 10) {
          barcodeHistory.removeLast();
        }
      }
    });
    await _saveBarcodeHistory();
  }

  void _updateHistory(List<String> newHistory) {
    setState(() {
      barcodeHistory = newHistory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Advanced Barcode Scanner'),
        backgroundColor: AppConstants.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeScannerHistory(
                    history: barcodeHistory,
                    onHistoryChanged: _updateHistory,
                  ),
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
                        builder: (context) => BarcodeDetailScreen(
                          barcodeData: scannedValue,
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
                        'Place a barcode in the camera view',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
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
                              builder: (context) => BarcodeScannerHistory(
                                history: barcodeHistory,
                                onHistoryChanged: _updateHistory,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 67, 100, 152),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppConstants.mainColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.history, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'View History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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
