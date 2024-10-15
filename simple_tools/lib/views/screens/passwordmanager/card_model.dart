import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';

class Cards {
  String bankname;
  String cardNumber;
  String imagePath;
  String cardHolderName;
  String cardExpiry;
  String cardCvv;

  Cards({
    required this.bankname,
    required this.imagePath,
    required this.cardNumber,
    required this.cardHolderName,
    required this.cardExpiry,
    required this.cardCvv,

  });

  // Convert a Cards object to a Map
  Map<String, dynamic> toJson() {
    return {
      'bankname':bankname,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'cardExpiry': cardExpiry,
      'cardCvv': cardCvv,
      'imagePath': imagePath,
    };
  }

  // Create a Cards object from a Map
  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
      bankname: json['bankname'],
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      cardExpiry: json['cardExpiry'],
      cardCvv: json['cardCvv'],
      imagePath: json['imagePath'],
    );
  }

  // Save a list of Cards to SharedPreferences
  static Future<void> saveCards(List<Cards> cards) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonCards = cards.map((card) => jsonEncode(card.toJson())).toList();
    await prefs.setStringList('saved_cards', jsonCards);
  }

  // Retrieve a list of Cards from SharedPreferences
  static Future<List<Cards>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonCards = prefs.getStringList('saved_cards');
    if (jsonCards == null) return [];
    return jsonCards.map((card) => Cards.fromJson(jsonDecode(card))).toList();
  }

  // Add a new card to the saved list
  static Future<void> addCard(Cards newCard) async {
    List<Cards> cards = await getCards();
    cards.add(newCard);
    await saveCards(cards);
  }

  // Delete a specific card based on card number
  static Future<void> deleteCard(String cardNumber) async {
    List<Cards> cards = await getCards();
    cards.removeWhere((card) => card.cardNumber == cardNumber);
    await saveCards(cards);
  }
}
