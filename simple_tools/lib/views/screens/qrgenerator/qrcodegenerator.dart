import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/qrgenerator/qrcodehistory.dart';

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  QRCodeGeneratorState createState() => QRCodeGeneratorState();
}

class QRCodeGeneratorState extends State<QRCodeGenerator> {
  String _qrData = '';
  String _selectedType = 'Text';
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRCodeHistory()),
              );
            },
            tooltip: 'View History',
          ),
        ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 24),
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildGenerateButton(),
              const SizedBox(height: 24),
              if (_qrData.isNotEmpty) _buildQRCodeCard(),
              if (_qrData.isNotEmpty) const SizedBox(height: 24),
              if (_qrData.isNotEmpty) _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select QR Code Type',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedType = newValue!;
                _qrData = '';
                _textController.clear();
              });
            },
            items: <String>[
              'Text',
              'Website',
              'File URL',
              'Image URL',
              'Google Location'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter $_selectedType Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInputWidget(),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: _generateQRCode,
      icon: const Icon(Icons.qr_code),
      label: const Text('Generate QR Code'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildQRCodeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Generated QR Code',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Center(
            child: RepaintBoundary(
              key: _qrKey,
              child: QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _saveQRCode,
      icon: const Icon(Icons.save),
      label: const Text('Save QR Code as a Picture'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildInputWidget() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: _getLabelText(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              prefixIcon: Icon(_getPrefixIcon()),
            ),
          ),
        ),
        if (_selectedType == 'File URL' || _selectedType == 'Image URL')
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
      ],
    );
  }

  String _getLabelText() {
    switch (_selectedType) {
      case 'Text':
        return 'Enter text';
      case 'Website':
        return 'Enter URL';
      case 'File URL':
        return 'Enter file URL';
      case 'Image URL':
        return 'Enter image URL';
      case 'Google Location':
        return 'Enter Google Maps URL or coordinates';
      default:
        return '';
    }
  }

  IconData _getPrefixIcon() {
    switch (_selectedType) {
      case 'Text':
        return Icons.text_fields;
      case 'Website':
        return Icons.link;
      case 'File URL':
        return Icons.insert_drive_file;
      case 'Image URL':
        return Icons.image;
      case 'Google Location':
        return Icons.location_on;
      default:
        return Icons.error;
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'How to Share ${_selectedType == 'File URL' ? 'PDF' : 'Image'} from Google Drive'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '1. Upload your ${_selectedType == 'File URL' ? 'PDF' : 'image'} to Google Drive'),
                const Text('2. Right-click on the file and select "Get link"'),
                const Text(
                    '3. Make sure the link is set to "Anyone with the link can view"'),
                const Text('4. Copy the link and paste it here'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateQRCode() async {
    setState(() {
      _qrData = _textController.text;
      _textController.clear();
    });
    await _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('qr_history') ?? [];
    final newItem = json.encode({
      'type': _selectedType,
      'data': _qrData,
      'timestamp': DateTime.now().toIso8601String(),
    });
    history.add(newItem);
    await prefs.setStringList('qr_history', history);
  }

  Future<void> _saveQRCode() async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final result = await FilePicker.platform.getDirectoryPath();
        if (result != null) {
          final directory = Directory(result);
          final file = File(
              '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(byteData.buffer.asUint8List());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('QR Code saved to ${file.path}')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error saving QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save QR Code')),
        );
      }
    }
  }
}
