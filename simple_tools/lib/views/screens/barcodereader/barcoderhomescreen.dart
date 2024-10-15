import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import '../../../util/history.dart';
import 'barcodedetailscreen.dart';
import 'barcodehistorylist.dart';

class Barcoder extends StatefulWidget {
  const Barcoder({super.key});

  @override
  State<Barcoder> createState() => _BarcoderState();
}

class _BarcoderState extends State<Barcoder> {
  String? scannedValue;
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text("Barcode Reader"),
        centerTitle: true,
        backgroundColor: Colors.brown.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // A banner section for future enhancements
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  "Align the barcode in the frame",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: Center(
                  child: isScanning
                      ? AiBarcodeScanner(
                    showSuccess: true,
                    hideSheetTitle: true,
                    hideSheetDragHandler: true,
                    onDetect: (BarcodeCapture capture) {
                      setState(() {
                        scannedValue = capture.barcodes.first.rawValue;
                        if (scannedValue != null) {
                          HistoryHelper.addBarcodeToHistory(scannedValue!);
                          isScanning = false;
                        }
                      });
                      debugPrint("Barcode scanned: $scannedValue");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BarcodeDetailsScreen(barcode: scannedValue!),
                        ),
                      );
                    },
                  )
                      : const Center(
                    child: Text(
                      'Scanner paused',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.brown.shade600,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(),
                    ),
                  );
                },
                label: const Text(
                  "View History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
