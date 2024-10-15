import 'package:flutter/material.dart';
import 'package:simple_tools/views/screens/passwordmanager/card_model.dart';

class CardDetailScreen extends StatefulWidget {
  final Cards card; // Receive a single Cards object.

  const CardDetailScreen({
    super.key,
    required this.card,
  });

  @override
  CardDetailScreenState createState() => CardDetailScreenState();
}

class CardDetailScreenState extends State<CardDetailScreen> {
  late TextEditingController _bankNameController;
  late TextEditingController _cardNumberController;
  late TextEditingController _cardHolderNameController;
  late TextEditingController _cardExpiryController;
  late TextEditingController _cardCvvController;

  bool _isEditing = false; // Flag to track if we are in editing mode

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current card data
    _bankNameController = TextEditingController(text: widget.card.bankname);
    _cardNumberController = TextEditingController(text: widget.card.cardNumber);
    _cardHolderNameController = TextEditingController(text: widget.card.cardHolderName);
    _cardExpiryController = TextEditingController(text: widget.card.cardExpiry);
    _cardCvvController = TextEditingController(text: widget.card.cardCvv);
  }

  @override
  void dispose() {
    // Dispose of controllers
    _bankNameController.dispose();
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Update card details (implement your logic to save changes)
    String updatedBankName = _bankNameController.text;
    String updatedCardNumber = _cardNumberController.text;
    String updatedCardHolderName = _cardHolderNameController.text;
    String updatedCardExpiry = _cardExpiryController.text;
    String updatedCardCvv = _cardCvvController.text;

    // Update the card object (assuming it's mutable)
    setState(() {
      widget.card.bankname = updatedBankName;
      widget.card.cardNumber = updatedCardNumber;
      widget.card.cardHolderName = updatedCardHolderName;
      widget.card.cardExpiry = updatedCardExpiry;
      widget.card.cardCvv = updatedCardCvv;
    });

    // Save to Shared Preferences
    await Cards.addCard(widget.card);

    if (!mounted) return;
    // Optionally, you can show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Card details updated successfully!')),
    );

    // Exit editing mode
    setState(() {
      _isEditing = false;
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.bankname),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isEditing ? _saveChanges : null, // Enable save only in edit mode
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _toggleEdit, // Toggle edit mode
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.card.imagePath.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          widget.card.imagePath,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Display or Edit Bank Name
                  _buildEditableField('Bank Name', _bankNameController, _isEditing),
                  const SizedBox(height: 10),

                  // Display or Edit Card Number
                  _buildEditableField('Card Number', _cardNumberController, _isEditing),
                  const SizedBox(height: 10),

                  // Display or Edit Card Holder Name
                  _buildEditableField('Card Holder Name', _cardHolderNameController, _isEditing),
                  const SizedBox(height: 10),

                  // Display or Edit Card Expiry
                  _buildEditableField('Card Expiry (MM/YY)', _cardExpiryController, _isEditing),
                  const SizedBox(height: 10),

                  // Display or Edit Card CVV
                  _buildEditableField('Card CVV', _cardCvvController, _isEditing, isPassword: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to create a display or editable field for each detail
  Widget _buildEditableField(String title, TextEditingController controller, bool isEditing, {bool isPassword = false}) {
    return GestureDetector(
      onTap: isEditing ? null : () => _toggleEdit(), // Only toggle edit mode if not already editing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          isEditing
              ? TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200], // Background color for text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              hintText: 'Enter $title',
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0), // Smaller padding
            ),
          )
              : Container(
            decoration: BoxDecoration(
              // Background color for read-only fields
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              controller.text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 15), // Space between fields
        ],
      ),
    );
  }
}
