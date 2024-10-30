import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../util/app_constants.dart';

class BarcodeScannerHistory extends StatefulWidget {
  final List<String> history;

  const BarcodeScannerHistory({super.key, required this.history});

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
                  onPressed: () {
                    setState(() {
                      _history.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
