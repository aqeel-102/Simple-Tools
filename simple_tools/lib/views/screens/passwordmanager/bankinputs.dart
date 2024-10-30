import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Bank {
  final String name;
  final String logo;

  Bank({required this.name, required this.logo});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      name: json['name'],
      logo: json['logo'],
    );
  }
}

class BankDataProvider {
  Future<List<Bank>> fetchBanks() async {
    final response = await http.get(
        Uri.parse('https://apisandbox.openbankproject.com/obp/v4.0.0/banks'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((bank) => Bank.fromJson(bank)).toList();
    } else {
      throw Exception('Failed to load banks');
    }
  }
}

class BankInput extends StatefulWidget {
  const BankInput({super.key});

  @override
  BankInputState createState() => BankInputState();
}

class BankInputState extends State<BankInput> {
  final TextEditingController _bankNameController = TextEditingController();
  List<Bank> _banks = [];
  List<Bank> _filteredBanks = [];
  String? _selectedBankLogo;

  @override
  void initState() {
    super.initState();
    fetchBankData();
  }

  Future<void> fetchBankData() async {
    BankDataProvider bankDataProvider = BankDataProvider();
    _banks = await bankDataProvider.fetchBanks();
  }

  void _filterBanks(String query) {
    setState(() {
      _filteredBanks = _banks
          .where(
              (bank) => bank.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectBank(Bank bank) {
    _bankNameController.text = bank.name;
    _selectedBankLogo = bank.logo;
    setState(() {
      _filteredBanks = [];
    });
  }

  Widget _buildBankNameAutocomplete() {
    return Column(
      children: [
        TextField(
          controller: _bankNameController,
          decoration: InputDecoration(
            labelText: 'Bank Name',
            border: OutlineInputBorder(),
          ),
          onChanged: _filterBanks,
        ),
        if (_filteredBanks.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _filteredBanks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredBanks[index].name),
                  leading: Image.network(_filteredBanks[index].logo),
                  onTap: () => _selectBank(_filteredBanks[index]),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCardInputFields() {
    return Column(
      children: [
        if (_selectedBankLogo != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              _selectedBankLogo!,
              width: 100,
              height: 50,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildBankNameAutocomplete(),
        ),
        // Other input fields (Account Name, Card Number, Expiry Date, CVV) can be added here
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildCardInputFields(),
    );
  }
}
