import 'package:flutter/material.dart';
import 'package:simple_tools/views/screens/zakatcalculator/zakathistory.dart';
import 'zakatscreen.dart';

class ZakatCalculatorApp extends StatefulWidget {
  @override
  State<ZakatCalculatorApp> createState() => _ZakatCalculatorAppState();
}

class _ZakatCalculatorAppState extends State<ZakatCalculatorApp> {


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Zakat Calculator',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          scaffoldBackgroundColor: Colors.blueGrey,
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
          ),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Center(child: Text("Zakat Calculator")),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/previousScreen'); // Replace '/previousScreen' with the correct route
                },
                icon: Icon(Icons.arrow_back),
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Container(
                  height: 280,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(4, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.blueGrey, width: 2),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      "Zakat, one of the core pillars of Islam, is a duty for all Muslims who have wealth that meets the Nisab threshold. Simply put, Nisab is the minimum amount a person must own before they’re required to pay Zakat. The threshold is based on the value of either 87.48 grams (7.5 tola) of gold or 612.36 grams (52.5 tola) of silver. If your assets exceed that amount, then Zakat becomes obligatory.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80),
              Column(
                children: [
                  Text(
                    "Use Our Zakat Calculator \n To Determine Your Zakat Amount",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ZakatCalculatorScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow,
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                        child: Text("Calculate Zakat"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ZakatHistoryList(), // Correctly pass zakatHistory
                              ),
                            );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow,
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                        child: Text("View History"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
