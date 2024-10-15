import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ZakatHistoryList extends StatefulWidget {
  const ZakatHistoryList({super.key});

  @override
  ZakatHistoryListState createState() => ZakatHistoryListState();
}

class ZakatHistoryListState extends State<ZakatHistoryList> {
  List<ZakatHistory> zakatHistory = [];

  @override
  void initState() {
    super.initState();
    _loadZakatHistory();  // Load the history when the screen starts
  }

  // Load Zakat history from SharedPreferences
  Future<void> _loadZakatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('zakatHistory');

    if (historyString != null) {
      final List<dynamic> historyList = json.decode(historyString);
      setState(() {
        zakatHistory = historyList
            .map((item) => ZakatHistory.fromMap(item))
            .toList();
      });
    }
  }

  // Save updated history to SharedPreferences
  Future<void> _saveZakatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
        zakatHistory.map((item) => item.toMap()).toList());
    await prefs.setString('zakatHistory', encodedData);
  }

  // Function to delete an entry from history
  void _deleteHistory(int index) {
    setState(() {
      zakatHistory.removeAt(index);  // Remove item from list
      _saveZakatHistory();  // Save updated list to SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zakat History'),
      ),
      body: zakatHistory.isNotEmpty
          ? ListView.builder(
        itemCount: zakatHistory.length,
        itemBuilder: (context, index) {
          final history = zakatHistory[index];
          return ListTile(
            title: Text(
                'Zakat Amount: \$${history.zakatAmount.toStringAsFixed(2)}'),
            subtitle: Text(
              'Total Assets: \$${history.totalAssets.toStringAsFixed(2)}\nDate: ${history.date.toLocal()}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Show a confirmation dialog before deleting
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete History'),
                      content: Text(
                          'Are you sure you want to delete this history entry?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();  // Close dialog
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteHistory(index);  // Delete the entry
                            Navigator.of(context).pop();  // Close dialog
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      )
          : Center(
        child: Text('No Zakat history available'),
      ),
    );
  }
}

class ZakatHistory {
  final DateTime date;
  final double zakatAmount;
  final double totalAssets;

  ZakatHistory({
    required this.date,
    required this.zakatAmount,
    required this.totalAssets,
  });

  // Convert ZakatHistory to a Map to store in SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'zakatAmount': zakatAmount,
      'totalAssets': totalAssets,
    };
  }

  // Create ZakatHistory from a Map
  factory ZakatHistory.fromMap(Map<String, dynamic> map) {
    return ZakatHistory(
      date: DateTime.parse(map['date']),
      zakatAmount: map['zakatAmount'],
      totalAssets: map['totalAssets'],
    );
  }
}
