import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_tools/views/screens/barcodegenerator/barcodehistory.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class BarcodeGeneratorMainScreen extends StatefulWidget {
  const BarcodeGeneratorMainScreen({super.key});

  @override
  _BarcodeGeneratorMainScreenState createState() =>
      _BarcodeGeneratorMainScreenState();
}

class _BarcodeGeneratorMainScreenState
    extends State<BarcodeGeneratorMainScreen> {
  String _barcodeData = '';
  BarcodeType _selectedBarcodeType = BarcodeType.Code128;
  double _barcodeWidth = 200;
  double _barcodeHeight = 80;
  List<Map<String, dynamic>> _history = [];

  final TextEditingController _dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.photos.request();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('barcode_history');
    if (historyJson != null) {
      setState(() {
        _history = List<Map<String, dynamic>>.from(json.decode(historyJson));
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('barcode_history', json.encode(_history));
  }

  void _addToHistory() {
    final newEntry = {
      'data': _barcodeData,
      'type': _selectedBarcodeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    setState(() {
      _history.insert(0, newEntry);
      if (_history.length > 10) {
        _history.removeLast();
      }
    });
    _saveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarcodeHistory(history: _history),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(
                labelText: 'Enter barcode data',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _barcodeData = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButton<BarcodeType>(
              value: _selectedBarcodeType,
              onChanged: (BarcodeType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedBarcodeType = newValue;
                  });
                }
              },
              items: BarcodeType.values.map((BarcodeType type) {
                return DropdownMenuItem<BarcodeType>(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _barcodeWidth,
                    min: 100,
                    max: 300,
                    divisions: 20,
                    label: _barcodeWidth.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _barcodeWidth = value;
                      });
                    },
                  ),
                ),
                const Text('Width'),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _barcodeHeight,
                    min: 50,
                    max: 200,
                    divisions: 15,
                    label: _barcodeHeight.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _barcodeHeight = value;
                      });
                    },
                  ),
                ),
                const Text('Height'),
              ],
            ),
            const SizedBox(height: 16),
            if (_barcodeData.isNotEmpty)
              BarcodeWidget(
                barcode: Barcode.fromType(_selectedBarcodeType),
                data: _barcodeData,
                width: _barcodeWidth,
                height: _barcodeHeight,
                color: Colors.black,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveBarcodeAsImage();
                _addToHistory();
              },
              child: const Text('Save Barcode'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBarcodeAsImage() async {
    if (_barcodeData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter barcode data')),
      );
      return;
    }

    try {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        if (!result.isGranted) {
          throw Exception('Storage permission is required to save the barcode');
        }
      }

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      final barcodeWidget = BarcodeWidget(
        barcode: Barcode.fromType(_selectedBarcodeType),
        data: _barcodeData,
        width: _barcodeWidth,
        height: _barcodeHeight,
        color: Colors.black,
      );
      barcodeWidget.build(context);
      final picture = recorder.endRecording();
      final img =
          await picture.toImage(_barcodeWidth.round(), _barcodeHeight.round());
      final pngBytes = await img.toByteData(format: ImageByteFormat.png);

      if (pngBytes != null) {
        final result = await ImageGallerySaver.saveImage(
          pngBytes.buffer.asUint8List(),
          quality: 100,
          name: 'barcode_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barcode saved to gallery')),
          );
        } else {
          throw Exception('Failed to save barcode to gallery');
        }
      } else {
        throw Exception('Failed to generate barcode image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save barcode: $e')),
      );
    }
  }
}
