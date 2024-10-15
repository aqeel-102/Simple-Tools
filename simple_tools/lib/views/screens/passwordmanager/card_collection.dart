import 'package:flutter/material.dart';
import 'card_model.dart';
import 'carddetails.dart'; // Ensure the path to card_model.dart is correct

class CardCollection extends StatefulWidget {
  const CardCollection({super.key});

  @override
  State<CardCollection> createState() => _CardCollectionState();
}

class _CardCollectionState extends State<CardCollection> {
  List<Cards> savedCardlist = []; // List to hold saved cards

  @override
  void initState() {
    super.initState();
    loadSelectedCards(); // Load cards when the widget is initialized
  }

  Future<void> loadSelectedCards() async {
    savedCardlist = await Cards.getCards(); // Use getCards method from Cards class
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Cards'),
      ),
      body: savedCardlist.isEmpty
          ? Center(child: Text('No saved cards found.'))
          : ListView.builder(
        itemCount: savedCardlist.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardDetailScreen(
                      card: savedCardlist[index], // Fixing syntax error here
                    ),
                  ),
                );
              },
              title: Text(savedCardlist[index].bankname), // Use bankname from Cards class
              subtitle: Text(savedCardlist[index].cardNumber), // Use cardNumber from Cards class
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteCard(savedCardlist[index].cardNumber); // Delete by card number
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Method to delete a card from the list
  void _deleteCard(String cardNumber) {
    Cards.deleteCard(cardNumber); // Call the deleteCard method from Cards class
    loadSelectedCards(); // Refresh the list after deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card deleted!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
