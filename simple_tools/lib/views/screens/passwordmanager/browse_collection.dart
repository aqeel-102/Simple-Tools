import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/passwordmanager/password_details.dart';
import 'package:simple_tools/views/screens/passwordmanager/password_model.dart';
class BrowseCollection extends StatefulWidget {
  const BrowseCollection({super.key});

  @override
  State<BrowseCollection> createState() => _BrowseCollectionState();
}

class _BrowseCollectionState extends State<BrowseCollection> {
  @override
  void initState() {
    super.initState();
    _loadAccounts(); // Load accounts when the widget is initialized
  }
  List<Password>savedBrowselist = [];

  Future<void> _loadAccounts() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? jsonString = sp.getString('browse');

    if (jsonString != null) {
      List<dynamic> jsonResponse = jsonDecode(jsonString);
      setState(() {
        savedBrowselist = jsonResponse.map((browse) => Password.fromJson(browse))
            .toList(); // Assuming Password has fromJson constructor
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Cards'),
      ),
      body: savedBrowselist.isEmpty
          ? Center(child: Text('No saved cards found.'))
          : ListView.builder(
        itemCount: savedBrowselist.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountDetailScreen(
                      account: savedBrowselist[index], // Fixing syntax error here
                    ),
                  ),
                );
              },
              title: Text(savedBrowselist[index].accountUsername), // Assuming Password has a title property
              subtitle: Text(savedBrowselist[index].email), // Assuming Password has a description property
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteCard(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to delete a card from the list
  void _deleteCard(int index) {
    setState(() {
      savedBrowselist.removeAt(index);
    });
    _saveUpdatedList(); // Save updated list to shared preferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Browse deleted!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Save the updated list back to shared preferences
  Future<void> _saveUpdatedList() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> jsonList = savedBrowselist.map((browse) => jsonEncode(browse.toJson())).toList(); // Assuming Password has toJson method
    await sp.setString('browse', jsonEncode(jsonList));
  }
}
