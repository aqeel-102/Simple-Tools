import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakatcalculations.dart';

class ZakatForm extends StatefulWidget {


  const ZakatForm({super.key, });


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

  bool _isLoading = false;

  Future<void> _calculateZakat() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final zakatCalculator = ZakatCalculator(
          gold: _parseValue(_goldController.text),
          silver: _parseValue(_silverController.text),
          cash: _parseValue(_cashController.text),
          businessAssets: _parseValue(_businessAssetsController.text),
          liabilities: _parseValue(_liabilitiesController.text),
        );

        final zakatAmount = await zakatCalculator.calculateZakat();
        int zakatval= zakatAmount as int;

        if (!mounted) return;

        if (zakatval == 0) {
          // Show alert dialog instead of SnackBar
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Zakat Eligibility'),
                content: Text('You are not eligible for zakat.'),
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
        } else {
          // Show alert dialog for successful calculation
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Zakat Calculated'),
                content: Text(zakatAmount.toString()), // Convert to string if zakatAmount is an int
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
        }
      } catch (e) {
        // Show alert dialog for failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Calculation Error'),
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

  double _parseValue(String value) {
    return value.isEmpty ? 0.0 : double.parse(value);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildTextField('Gold (in PKR)', _goldController),
            _buildTextField('Silver (in PKR)', _silverController),
            _buildTextField('Cash Savings(in PKR)', _cashController),
            _buildTextField('Business Assets (In PKR)', _businessAssetsController),
            _buildTextField('Liabilities (In PKR)', _liabilitiesController),
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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      maxLength: 15,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null; // Allow empty fields
        }
        try {
          double.parse(value); // Check if it's a valid number
        } catch (e) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
