import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class BarcodeHistory extends StatefulWidget {
  final List<Map<String, dynamic>> history;

  const BarcodeHistory({super.key, required this.history});

  @override
  _BarcodeHistoryState createState() => _BarcodeHistoryState();
}

class _BarcodeHistoryState extends State<BarcodeHistory> {
  Future<void> _saveImage(Map<String, dynamic> barcode) async {
    if (barcode['data'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No barcode data to save')),
      );
      return;
    }

    try {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final barcodeWidget = BarcodeWidget(
        barcode: Barcode.fromType(BarcodeType.values.firstWhere(
            (type) => type.toString().split('.').last == barcode['type'],
            orElse: () => BarcodeType.Code128)),
        data: barcode['data'],
        width: 200,
        height: 80,
      );
      barcodeWidget.build(context);
      final picture = recorder.endRecording();
      final img = await picture.toImage(200, 80);
      final pngBytes = await img.toByteData(format: ImageByteFormat.png);

      if (pngBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
            '${directory.path}/barcode_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(pngBytes.buffer.asUint8List());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Barcode saved to ${file.path}')),
        );
      } else {
        throw Exception('Failed to generate barcode image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save barcode: $e')),
      );
    }
  }

  void _deleteBarcode(int index) {
    setState(() {
      widget.history.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode History'),
      ),
      body: widget.history.isEmpty
          ? const Center(
              child: Text('No barcode history available.'),
            )
          : ListView.builder(
              itemCount: widget.history.length,
              itemBuilder: (context, index) {
                final barcode = widget.history[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      BarcodeWidget(
                        barcode: Barcode.fromType(BarcodeType.values.firstWhere(
                            (type) =>
                                type.toString().split('.').last ==
                                barcode['type'],
                            orElse: () => BarcodeType.Code128)),
                        data: barcode['data'],
                        width: 200,
                        height: 80,
                      ),
                      ListTile(
                        title: Text(barcode['data']),
                        subtitle: Text('Type: ${barcode['type']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: () => _saveImage(barcode),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteBarcode(index),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
