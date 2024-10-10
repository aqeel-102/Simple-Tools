import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../util/history.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> barcodeHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Load barcode history from SharedPreferences
  void _loadHistory() async {
    List<String> history = await HistoryHelper.getBarcodeHistory();
    setState(() {
      barcodeHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barcode History"),
      ),
      body: ListView.builder(
        itemCount: barcodeHistory.length,
        itemBuilder: (context, index) {
          final code = barcodeHistory[index];
          return ListTile(
            title: Text(code),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
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
