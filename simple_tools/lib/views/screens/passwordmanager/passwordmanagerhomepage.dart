import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tools/views/screens/passwordmanager/landingforpasswordmanager';
import 'package:simple_tools/views/screens/passwordmanager/password_details.dart';
import 'package:simple_tools/views/screens/passwordmanager/password_model.dart';
import 'package:simple_tools/views/screens/passwordmanager/passwordsetup.dart';
import '../../../util/images.dart';
import 'browse_collection.dart';
import 'card_collection.dart';
import 'card_model.dart';
import 'carddetails.dart';
import 'login_collection.dart';

enum InputType {
  user, // For user-related fields
  card, // For card-related fields
}

class PasswordManagerHomePage extends StatefulWidget {
  const PasswordManagerHomePage({super.key});

  @override
  PasswordManagerHomePageState createState() => PasswordManagerHomePageState();
}

class PasswordManagerHomePageState extends State<PasswordManagerHomePage> {
  // Text controllers
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController accountType = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _banknameController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  List<Password> accounts = [];
  List<Cards> cardaccount = [];
  List<Password> login = [];
  List<Password> browse = [];
  List<Cards> card = [];
  int selectedList = 1;

  String _selectedIcon = Images.defaultval;
  final List<String> _availableIcons = [
    Images.linkedin,
    Images.instagram,
    Images.netflix,
    Images.google,
    Images.facebook,
    Images.whatsapp,
    Images.card,
    Images.defaultval
  ];

  String _detectCardType(String cardNumber) {
    cardNumber = cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');

    // Visa
    if (RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$').hasMatch(cardNumber)) {
      return Images.visa;
    }
    // Mastercard
    else if (RegExp(r'^5[1-5][0-9]{14}$|^2[2-7][0-9]{14}$')
        .hasMatch(cardNumber)) {
      return Images.mastercard;
    }
    // American Express
    else if (RegExp(r'^3[47][0-9]{13}$').hasMatch(cardNumber)) {
      return Images.amex;
    }
    // Discover
    else if (RegExp(r'^6(?:011|5[0-9]{2})[0-9]{12}$').hasMatch(cardNumber)) {
      return Images.discover;
    }
    // JCB
    else if (RegExp(r'^(?:2131|1800|35\d{3})\d{11}$').hasMatch(cardNumber)) {
      return Images.jcb;
    }
    // Diners Club
    else if (RegExp(r'^3(?:0[0-5]|[68][0-9])[0-9]{11}$').hasMatch(cardNumber)) {
      return Images.dinersclub;
    }
    // UnionPay
    else if (RegExp(r'^(62|88)\d{14,17}$').hasMatch(cardNumber)) {
      return Images.unionpay;
    }
    // Maestro
    else if (RegExp(r'^(5018|5020|5038|6304|6759|6761|6763)[0-9]{8,15}$')
        .hasMatch(cardNumber)) {
      return Images.maestro;
    }
    // Default card image if no match
    return Images.card;
  }

  // Function to show the icon picker dialog
  void _showIconPicker() async {
    final String? pickedIcon = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an Icon'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconPath = _availableIcons[index];
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(
                          _availableIcons[index]); // Return selected icon path
                    },
                    child: Image.asset(iconPath)
                    //Image(iconPath, width: 50, height: 50),
                    );
              },
            ),
          ),
        );
      },
    );

    if (pickedIcon != null) {
      setState(() {
        _selectedIcon = pickedIcon; // Update selected icon
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts(); // Load accounts when the widget is initialized
  }

  // Function to load accounts from SharedPreferences
  Future<void> _loadAccounts() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? jsonString = sp.getString('savedlist');

    if (jsonString != null) {
      List<dynamic> jsonResponse = jsonDecode(jsonString);
      setState(() {
        accounts = jsonResponse
            .map((account) => Password.fromJson(account))
            .toList(); // Assuming Password has fromJson constructor
      });
    }

    // Load cards
    setState(() async {
      cardaccount = await Cards.getCards();
    });
  }

  void saveValues() {
    if (usernameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      Password newAccount = Password(
        accountUsername: usernameController.text,
        email: emailController.text,
        imagePath: _selectedIcon, // Use the selected icon
        password: passwordController.text,
      );

      setState(() {
        accounts.add(newAccount);
      });

      savingintosharedprefernce(accounts); // Save to SharedPreferences

      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account Added Successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Clear the controllers after saving
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      accountType.clear();

      // Close the bottom sheet after saving
      Navigator.pop(context);
    } else {
      accountType.clear();
      _selectedIcon = Images.defaultval;
      Navigator.pop(context);
      // Show error Snackbar if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void saveCardvalues() {
    if (_banknameController.text.isNotEmpty &&
        _cardHolderNameController.text.isNotEmpty &&
        _cardNumberController.text.isNotEmpty &&
        _expiryDateController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty) {
      // Create a new Cards object with input values
      Cards newCard = Cards(
        imagePath: _selectedIcon,
        cardNumber: _cardNumberController.text,
        cardHolderName: _cardHolderNameController.text,
        cardExpiry: _expiryDateController.text,
        cardCvv: _cvvController.text,
        bankname: _banknameController.text,
      );

      setState(() {
        cardaccount.add(newCard); // Add to the list of accounts/cards
      });

      // Save updated list to SharedPreferences
      Cards.saveCards(cardaccount);

      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card Added Successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Clear the controllers after saving
      _banknameController.clear();
      _cardHolderNameController.clear();
      _cardNumberController.clear();
      _expiryDateController.clear();
      _cvvController.clear();

      // Close the bottom sheet after saving
      Navigator.pop(context);
    } else {
      // Close the bottom sheet and show error Snackbar if fields are empty
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> savingintosharedprefernce(List<Password> accounts) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String afterjsonencode = jsonEncode(accounts
        .map((account) => account.toJson())
        .toList()); // Convert list of Password objects to JSON
    await sp.setString('savedlist', afterjsonencode);
  }

  Future<void> savingselectedsharedprefernce(List<Password> selected) async {
    SharedPreferences sp1 = await SharedPreferences.getInstance();

    String loginjson =
        jsonEncode(login.map((login) => login.toJson()).toList());
    String browsejson =
        jsonEncode(browse.map((browse) => browse.toJson()).toList());

    await sp1.setString('login', loginjson);
    await sp1.setString('browse', browsejson);
  }

  Future<void> savingextraselectedsharedprefernce(List<Cards> selected) async {
    SharedPreferences sp1 = await SharedPreferences.getInstance();

    String cardjson = jsonEncode(selected
        .map((card) => card.toJson())
        .toList()); // Use 'selected' instead of 'card'

    await sp1.setString('card', cardjson);
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    accountType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Example password list

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 141, 173, 228),
        title: Text('Password Manager'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordSetup()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          _showBottomSheet(context, InputType.user);
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  _showBottomSheet(context, InputType.card);
                },
                icon: const Icon(Icons.add_card_outlined),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final bool? isPasswordEnabled =
                      prefs.getBool('password_enabled');

                  if (isPasswordEnabled == true) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Lock App'),
                          content: const Text('Do you want to lock the app?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LandingForPasswordManager(),
                                  ),
                                );
                              },
                              child: const Text('Lock'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                icon: const Icon(Icons.shield_outlined),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _searchInput('Search Password'),

                SizedBox(height: 20),

                // Category Section
                Text('Category',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginCollection()));
                      },
                      child: _buildCategoryButton(
                          'login', Icons.vpn_key, Colors.blue[100]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BrowseCollection()));
                      },
                      child: _buildCategoryButton(
                          'browse', Icons.web, Colors.green[100]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CardCollection()));
                      },
                      child: _buildCategoryButton(
                          'card', Icons.credit_card, Colors.pink[100]),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tab-like Buttons for Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => selectedList = 1),
                              style: TextButton.styleFrom(
                                backgroundColor: selectedList == 1
                                    ? Colors.grey
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                              child: Text(
                                'Passwords',
                                style: TextStyle(
                                  color: selectedList == 1
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => selectedList = 2),
                              style: TextButton.styleFrom(
                                backgroundColor: selectedList == 2
                                    ? Colors.grey
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                              child: Text(
                                'Cards',
                                style: TextStyle(
                                  color: selectedList == 2
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List View Based on Selected Tab
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: selectedList == 1
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 350,
                                  child: ListView.separated(
                                    itemCount: accounts.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AccountDetailScreen(
                                                account: accounts[index],
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildRecentUsedItem(
                                          'account',
                                          index,
                                          accounts[index].accountUsername,
                                          accounts[index].email,
                                          accounts[index].imagePath,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 350,
                                  child: ListView.separated(
                                    itemCount: cardaccount.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CardDetailScreen(
                                                card: cardaccount[index],
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildRecentUsedItem(
                                          'card',
                                          index,
                                          cardaccount[index].bankname,
                                          cardaccount[index].cardHolderName,
                                          cardaccount[index].imagePath,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget to build each category button
  Widget _buildCategoryButton(
    String label,
    IconData icon,
    Color? color,
  ) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 30, color: Colors.black),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  // Widget to build recent used item
  Widget _buildRecentUsedItem(
      String type, int index, String title, String email, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onLongPress: () => _showPopupMenu(context, index, type),
        child: ListTile(
          leading: Image.asset(imagePath, height: 40, width: 40),
          title: Text(
            '@$title',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            email,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // Bottom sheet function
  void _showBottomSheet(BuildContext context, InputType inputType) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return _bottomSheet(inputType: inputType);
      },
    );
  }

  // Bottom sheet widget
  Widget _bottomSheet({required InputType inputType}) {
    return Wrap(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Divider
                _buildDivider(),
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Your Friendly Password Manager',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (inputType == InputType.user) ...[
                  _iconSelector(),
                ] else ...[
                  Image.asset(_selectedIcon, height: 40, width: 40),
                ],
                const SizedBox(height: 20),
                // Input Fields
                if (inputType == InputType.user) ...[
                  _buildUserInputFields(),
                ] else if (inputType == InputType.card) ...[
                  _buildCardInputFields(),
                ],
                const SizedBox(height: 24),
                // Save Button
                _mainButton('Save',
                    inputType == InputType.user ? saveValues : saveCardvalues),
              ],
            ),
          ),
        ),
      ],
    );
  }

// Method to build the divider
  Widget _buildDivider() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

// Method to build user input fields
  Widget _buildUserInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _enterInput(
                'Account Type',
                Icons.perm_identity,
                accountType,
                TextInputType.name,
                30,
                onChanged: (value) {
                  _updateIcon(); // Call _updateIcon when the user submits the account type
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: _enterInput('Username', Icons.perm_identity,
                    usernameController, TextInputType.name, 30)),
          ],
        ),
        const SizedBox(height: 16),
        _enterInput('E-mail', Icons.mail_outline_outlined, emailController,
            TextInputType.emailAddress, 320),
        const SizedBox(height: 16),
        _enterInput('Password', Icons.lock_outline, passwordController,
            TextInputType.visiblePassword, 15),
      ],
    );
  }

// Method to build card input fields
  Widget _buildCardInputFields() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _enterInput('Bank Name', Icons.account_balance_outlined,
              _banknameController, TextInputType.name, 30),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 16,
            onChanged: (value) {
              setState(() {
                _selectedIcon = _detectCardType(value);
              });
            },
            decoration: InputDecoration(
              labelText: 'Card Number',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _enterInput('Account Name', Icons.perm_identity,
              _cardHolderNameController, TextInputType.name, 30),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _enterInput('Expiry Date', Icons.calendar_month_outlined,
              _expiryDateController, TextInputType.datetime, 10),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _enterInput('Cvv', Icons.account_balance_wallet_outlined,
              _cvvController, TextInputType.number, 3),
        ),
      ],
    );
  }

  Widget _iconSelector() {
    return GestureDetector(
      onTap: _showIconPicker, // Show icon picker on tap
      child: Column(
        children: [
          // Display the selected icon
          Image.asset(_selectedIcon, width: 50, height: 50),
          SizedBox(height: 8),
          Text('Tap to change icon', style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _searchInput(String label) {
    return TextField(
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _enterInput(
    String label,
    IconData icon,
    TextEditingController controller,
    TextInputType keyboardType,
    int length, {
    void Function(String)?
        onChanged, // Change from VoidCallback to Function(String)
  }) {
    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      maxLength: length,
      onSubmitted: onChanged, // Set the onSubmitted callback here
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _mainButton(String name, onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, int index, String type) async {
    final result = await showMenu(
      context: context,
      position: RelativeRect.fill,
      items: [
        PopupMenuItem(
          value: 'delete',
          child: ListTile(leading: Icon(Icons.delete), title: Text('Delete')),
        ),
        PopupMenuItem(
          value: 'album',
          child:
              ListTile(leading: Icon(Icons.album), title: Text('Add to Album')),
        ),
      ],
    );

    if (result == 'delete') {
      setState(() {
        if (type == 'account') {
          accounts.removeAt(index); // Delete from accounts list
        } else if (type == 'card') {
          cardaccount.removeAt(index); // Delete from card list
        }
      });

      await savingintosharedprefernce(
          accounts); // Make sure this function can handle both lists
      await Cards.saveCards(cardaccount);
      if (!mounted) return;
    } else if (result == 'album') {
      _showOptionsDialog(context, index, type);
    }
  }

  void _showOptionsDialog(BuildContext context, int index, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Where To Save'),
          content: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: 120, // Adjust this height as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Only show this button if the type is 'account'
                  if (type == 'account') ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          login.add(
                              accounts[index]); // Add to recommended login list
                        });
                        savingselectedsharedprefernce(
                            login); // Save recommended login accounts
                        Navigator.pop(context); // Close dialog
                        _showSnackBar(
                            context, 'Added to Login'); // Show a message
                      },
                      child: _buildCategoryButton(
                          'login', Icons.vpn_key, Colors.blue[100]!),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          browse.add(accounts[
                              index]); // Add to recommended browse list
                        });
                        savingselectedsharedprefernce(
                            browse); // Save recommended browse accounts
                        Navigator.pop(context); // Close dialog
                        _showSnackBar(
                            context, 'Added to Browse'); // Show a message
                      },
                      child: _buildCategoryButton(
                          'browse', Icons.web, Colors.green[100]!),
                    ),
                  ],

                  // Only show this button if the type is 'card'
                  if (type == 'card') ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          card.add(cardaccount[
                              index]); // Add to recommended card list
                        });
                        savingextraselectedsharedprefernce(
                            card); // Save recommended card accounts
                        Navigator.pop(context); // Close dialog
                        _showSnackBar(
                            context, 'Added to Card'); // Show a message
                      },
                      child: _buildCategoryButton(
                          'card', Icons.credit_card, Colors.pink[100]!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updateIcon() {
    String input = accountType.text.toLowerCase(); // Convert to lowercase
    setState(() {
      // Match the icon based on input text
      if (input.contains('google')) {
        _selectedIcon = Images.google;
      } else if (input.contains('facebook')) {
        _selectedIcon = Images.facebook;
      } else if (input.contains('linkedin')) {
        _selectedIcon = Images.linkedin;
      } else if (input.contains('whatsapp')) {
        _selectedIcon = Images.whatsapp;
      } else if (input.contains('instagram')) {
        _selectedIcon = Images.instagram;
      } else if (input.contains('netflix')) {
        _selectedIcon = Images.netflix;
      } else {
        _selectedIcon = Images.defaultval; // Default icon
      }
    });
  }
}
