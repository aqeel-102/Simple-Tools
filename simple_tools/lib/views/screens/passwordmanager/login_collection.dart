
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/passwordmanager/password_details.dart';
import 'package:simple_tools/views/screens/passwordmanager/password_model.dart';
class LoginCollection extends StatefulWidget {
  const LoginCollection({super.key});

  @override
  State<LoginCollection> createState() => _LoginCollectionState();
}

class _LoginCollectionState extends State<LoginCollection> {
  @override
  void initState() {
    super.initState();
    _loadAccounts(); // Load accounts when the widget is initialized
  }
  List<Password>savedLoginlist = [];

  Future<void> _loadAccounts() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? jsonString = sp.getString('login');

    if (jsonString != null) {
      List<dynamic> jsonResponse = jsonDecode(jsonString);
      setState(() {
        savedLoginlist = jsonResponse.map((login) => Password.fromJson(login))
            .toList(); // Assuming Password has fromJson constructor
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Login'),
      ),
      body: savedLoginlist.isEmpty
          ? Center(child: Text('No Logins found.'))
          : ListView.builder(
        itemCount: savedLoginlist.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountDetailScreen(
                      account: savedLoginlist[index], // Fixing syntax error here
                    ),
                  ),
                );
              },
              title: Text(savedLoginlist[index].accountUsername), // Displaying username
              subtitle: Text(savedLoginlist[index].email), // Displaying email as subtitle
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteCard(index); // Calling delete method
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
      savedLoginlist.removeAt(index);
    });
    _saveUpdatedList(); // Save updated list to shared preferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card deleted!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Save the updated list back to shared preferences
  Future<void> _saveUpdatedList() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> jsonList = savedLoginlist.map((login) => jsonEncode(login.toJson())).toList(); // Assuming Password has toJson method
    await sp.setString('login', jsonEncode(jsonList));
  }
}
