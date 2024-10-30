import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';

class QRCodeHistory extends StatefulWidget {
  const QRCodeHistory({super.key});

  @override
  QRCodeHistoryState createState() => QRCodeHistoryState();
}

class QRCodeHistoryState extends State<QRCodeHistory> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('qr_history') ?? [];
    setState(() {
      _history = historyList
          .map((item) => json.decode(item) as Map<String, dynamic>)
          .toList();
      _history.sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));
    });
  }

  Future<void> _deleteHistoryItem(int index) async {
    setState(() {
      _history.removeAt(index);
    });
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = _history.map((item) => json.encode(item)).toList();
    await prefs.setStringList('qr_history', historyList);
  }

  Future<void> _saveQRCodeAsImage(String data) async {
    final qrKey = GlobalKey();
    final qrImage = RepaintBoundary(
      key: qrKey,
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: 200.0,
        backgroundColor: Colors.white,
      ),
    );

    final BuildContext? context = qrKey.currentContext;
    if (context == null) return;

    final RenderRepaintBoundary boundary =
        context.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('QR Code saved to $filePath')),
      );
    }
  }

  void _showOptionsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Code Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save as Image'),
                onTap: () {
                  Navigator.of(context).pop();
                  _saveQRCodeAsImage(item['data']);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteHistoryItem(_history.indexOf(item));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code History'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: _history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No history available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Card(
                    elevation: 2,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _showOptionsDialog(item),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['type'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['data'],
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM d, yyyy HH:mm').format(
                                        DateTime.parse(item['timestamp'])),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            QrImageView(
                              data: item['data'],
                              version: QrVersions.auto,
                              size: 100.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
