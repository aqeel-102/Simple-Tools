import 'package:flutter/material.dart';

class CardType {
  final String name;
  final String logo;
  final String pattern;

  CardType({required this.name, required this.logo, required this.pattern});
}

class BankInput extends StatefulWidget {
  const BankInput({super.key});

  @override
  BankInputState createState() => BankInputState();
}

class BankInputState extends State<BankInput> {
  final TextEditingController _cardNumberController = TextEditingController();
  String? _selectedCardLogo;

  // List of card types with their regex patterns
  final List<CardType> cardTypes = [
    CardType(
        name: 'Visa',
        logo: 'assets/images/visa.png',
        pattern: r'^4[0-9]{12}(?:[0-9]{3})?$'),
    CardType(
        name: 'Mastercard',
        logo: 'assets/images/mastercard.png',
        pattern: r'^5[1-5][0-9]{14}$'),
    CardType(
        name: 'American Express',
        logo: 'assets/images/amex.png',
        pattern: r'^3[47][0-9]{13}$'),
    CardType(
        name: 'Discover',
        logo: 'assets/images/discover.png',
        pattern: r'^6(?:011|5[0-9]{2})[0-9]{12}$'),
  ];

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_updateCardLogo);
  }

  void _updateCardLogo() {
    String cardNumber =
        _cardNumberController.text.replaceAll(RegExp(r'\s+\b|\b\s'), '');

    setState(() {
      _selectedCardLogo = null;
      for (var cardType in cardTypes) {
        if (RegExp(cardType.pattern).hasMatch(cardNumber)) {
          _selectedCardLogo = cardType.logo;
          break;
        }
      }
    });
  }

  Widget _buildCardInputFields() {
    return Column(
      children: [
        if (_selectedCardLogo != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              _selectedCardLogo!,
              width: 100,
              height: 50,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(),
            ),
            maxLength: 19,
          ),
        ),
        // Additional card input fields can be added here
        // Like card holder name, expiry date, CVV etc.
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildCardInputFields(),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    super.dispose();
  }
}
