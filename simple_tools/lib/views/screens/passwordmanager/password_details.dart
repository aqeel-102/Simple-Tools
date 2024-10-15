import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/passwordmanager/password_model.dart';

class AccountDetailScreen extends StatefulWidget {
  final Password account; // Receive a single Password object.

  const AccountDetailScreen({
    super.key,
    required this.account,
  });

  @override
  AccountDetailScreenState createState() => AccountDetailScreenState();
}

class AccountDetailScreenState extends State<AccountDetailScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _isEditing = false; // Flag to track if we are in editing mode

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current account data
    _usernameController = TextEditingController(text: widget.account.accountUsername);
    _emailController = TextEditingController(text: widget.account.email);
    _passwordController = TextEditingController(text: widget.account.password);
  }

  @override
  void dispose() {
    // Dispose of controllers
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Update account details (implement your logic to save changes)
    String updatedUsername = _usernameController.text;
    String updatedEmail = _emailController.text;
    String updatedPassword = _passwordController.text;

    // Update the account object (assuming it's mutable)
    setState(() {
      widget.account.accountUsername = updatedUsername;
      widget.account.email = updatedEmail;
      widget.account.password = updatedPassword;
    });

    // Save to Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', updatedUsername);
    await prefs.setString('email', updatedEmail);
    await prefs.setString('password', updatedPassword);
    if (!mounted) return;
    // Optionally, you can show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account details updated successfully!')),
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
        title: Text(widget.account.accountUsername),
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
                  // Display account image if available
                  if (widget.account.imagePath.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          widget.account.imagePath,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Display or Edit Account Username
                  _buildEditableField('Username', _usernameController, _isEditing),
                  const SizedBox(height: 10),

                  // Display or Edit Account Email
                  _buildEditableField('Email', _emailController, _isEditing),
                  const SizedBox(height: 10),

                  // Display or Edit Account Password
                  _buildEditableField('Password', _passwordController, _isEditing, isPassword: true),
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
            obscureText: isPassword,
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
