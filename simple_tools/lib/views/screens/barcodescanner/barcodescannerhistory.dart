import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../util/app_constants.dart';

class BarcodeScannerHistory extends StatefulWidget {
  final List<String> history;
  final Function(List<String>)? onHistoryChanged;

  const BarcodeScannerHistory({
    super.key,
    required this.history,
    this.onHistoryChanged,
  });

  @override
  _BarcodeScannerHistoryState createState() => _BarcodeScannerHistoryState();
}

class _BarcodeScannerHistoryState extends State<BarcodeScannerHistory> {
  late List<String> _history;

  @override
  void initState() {
    super.initState();
    _history = List.from(widget.history);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (_history.isEmpty) {
      await prefs.remove('barcode_history');
    } else {
      await prefs.setString('barcode_history', json.encode(_history));
    }
  }

  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                setState(() {
                  _history.removeAt(index);
                });
                await _saveHistory();
                widget.onHistoryChanged?.call(_history);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scan History'),
        backgroundColor: AppConstants.mainColor,
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final code = _history[index];
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
                          content: Text(AppConstants.codeCopiedToClipboard)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
