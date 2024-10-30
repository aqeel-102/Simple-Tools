import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakatcalculations.dart';

class ZakatForm extends StatefulWidget {
  const ZakatForm({super.key});

  @override
  ZakatFormState createState() => ZakatFormState();
}

class ZakatFormState extends State<ZakatForm> {
  final _formKey = GlobalKey<FormState>();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _cashController = TextEditingController();
  final _businessAssetsController = TextEditingController();
  final _liabilitiesController = TextEditingController();

  String? selectedValue; // Selected value for the dropdown
  final List<String> unitOfMeasurement = ['kg', 'g', 'toz'];

  String? selectedCurrency; // Selected value for the dropdown
  final List<String> currency = ['USD', 'PKR', 'EUR'];

  bool _isLoading = false;

  // New variables to control TextField availability
  bool get _isFormEnabled => selectedValue != null && selectedCurrency != null;

  Future<void> _calculateZakat() async {
    if (_formKey.currentState!.validate()) {
      // Fill empty fields with '0'
      _fillEmptyFieldsWithZero();

      setState(() {
        _isLoading = true;
      });
      try {
        final zakatCalculator = ZakatCalculator(
          unit: selectedValue!,
          currency: selectedCurrency!.toUpperCase(), // Convert to uppercase
          gold: _parseValue(_goldController.text),
          silver: _parseValue(_silverController.text),
          cash: _parseValue(_cashController.text),
          businessAssets: _parseValue(_businessAssetsController.text),
          liabilities: _parseValue(_liabilitiesController.text),
        );

        final zakatAmount = await zakatCalculator.calculateZakat();

        if (!mounted) return;

        // Show alert dialog for successful calculation or no internet
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(zakatAmount.startsWith('No internet')
                  ? 'Network Error'
                  : 'Zakat Calculated'),
              content: Text(zakatAmount),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Show alert dialog for failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(child: Text('Calculation Error')),
              content: Text('Failed to calculate Zakat: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // New method to fill empty fields with '0'
  void _fillEmptyFieldsWithZero() {
    if (_goldController.text.isEmpty) _goldController.text = '0';
    if (_silverController.text.isEmpty) _silverController.text = '0';
    if (_cashController.text.isEmpty) _cashController.text = '0';
    if (_businessAssetsController.text.isEmpty) {
      _businessAssetsController.text = '0';
    }
    if (_liabilitiesController.text.isEmpty) _liabilitiesController.text = '0';
  }

  double _parseValue(String value) {
    return value.isEmpty ? 0.0 : double.parse(value);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                      border: Border.all(color: Colors.grey), // Border color
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Center(
                          child: Text(
                            'Unit',
                            style: TextStyle(
                                color: Colors.grey[600]), // Hint text style
                          ),
                        ),
                        value: selectedValue,
                        items: unitOfMeasurement.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item,
                                style: TextStyle(
                                    color: Colors.black), // Item text style
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                        },
                        isExpanded: true, // Make the dropdown full width
                        style: TextStyle(
                            color: Colors.black), // Dropdown text style
                        iconEnabledColor: Colors.grey[600], // Icon color
                        iconSize: 24, // Icon size
                        dropdownColor: Colors.white, // Dropdown menu color
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                      border: Border.all(color: Colors.grey), // Border color
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Center(
                          child: Text(
                            'Currency',
                            style: TextStyle(
                                color: Colors.grey[600]), // Hint text style
                          ),
                        ),
                        value: selectedCurrency,
                        items: currency.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item,
                                style: TextStyle(
                                    color: Colors.black), // Item text style
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCurrency = newValue!;
                          });
                        },
                        isExpanded: true, // Make the dropdown full width
                        style: TextStyle(
                            color: Colors.black), // Dropdown text style
                        iconEnabledColor: Colors.grey[600], // Icon color
                        iconSize: 24, // Icon size
                        dropdownColor: Colors.white, // Dropdown menu color
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildTextField(
                'Gold ( ${selectedValue ?? 'unit'})', _goldController),
            _buildTextField(
                'Silver ( ${selectedValue ?? 'unit'})', _silverController),
            _buildTextField('Cash Savings ( ${selectedCurrency ?? 'currency'})',
                _cashController),
            _buildTextField(
                'Business Assets ( ${selectedCurrency ?? 'currency'})',
                _businessAssetsController),
            _buildTextField('Liabilities ( ${selectedCurrency ?? 'currency'})',
                _liabilitiesController),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _calculateZakat,
                    child: Text('Calculate Zakat'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: '0.0', // Use a string to represent the hint
          hintStyle: TextStyle(color: Colors.grey[400]), // Hint text style
          counterStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.black54), // Label style
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            borderSide:
                BorderSide(color: Colors.grey), // Border color when not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            borderSide: BorderSide(
                color: Colors.black45, width: 2.0), // Border color when focused
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            borderSide: BorderSide(
                color: Colors.red, width: 2.0), // Border color when error
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            borderSide: BorderSide(
                color: Colors.red,
                width: 2.0), // Border color when focused and error
          ),
          contentPadding: EdgeInsets.symmetric(
              vertical: 12.0, horizontal: 10.0), // Internal padding
        ),
        keyboardType: TextInputType.number,
        maxLength: 15,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        enabled: _isFormEnabled, // Enable/disable based on selection
        validator: (value) {
          if (!_isFormEnabled) {
            _showSnackbar('Please select unit and currency first');
            return null;
          }
          if (value != null && value.isNotEmpty) {
            try {
              double.parse(value); // Check if it's a valid number
            } catch (e) {
              return 'Please enter a valid number';
            }
          }
          return null; // Allow empty fields, they will be filled with '0' later
        },
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
