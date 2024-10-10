import 'package:flutter/material.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakatcalculations.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakatinputform.dart';
class ZakatCalculatorScreen extends StatefulWidget {

  @override
  _ZakatCalculatorScreenState createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zakat Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the screen
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ZakatForm(

                ), // Pass the add history function
              ),
            ),
          ],
        ),
      ),
    );
  }
}