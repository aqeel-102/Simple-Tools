import 'package:flutter/material.dart';
import 'package:simple_tools/util/app_constants.dart';
import 'package:simple_tools/views/screens/barcodescanner/barcodescanner.dart';
import 'package:simple_tools/views/screens/deviceinfo/deviceinfohomepage';
import 'package:simple_tools/views/screens/qrgenerator/qrcodegenerator.dart';

class UtilitiesPage extends StatelessWidget {
  const UtilitiesPage({super.key});

  Widget _buildToolCard({
    required String title,
    required Widget nextScreen,
    required IconData icon,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.mainColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppConstants.mainColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show dialog to add new tool
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add New Tool'),
            content: const Text('Feature coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppConstants.mainColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: AppConstants.mainColor,
            ),
            const SizedBox(height: 12),
            const Text(
              'Add New Tool',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Utility Tools',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Helpful utilities for everyday use',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildToolCard(
                      title: AppConstants.barCode,
                      nextScreen: const BarcodeScanner(),
                      icon: Icons.qr_code_scanner_rounded,
                    ),
                    _buildToolCard(
                      title: AppConstants.qrCodeGenerator,
                      nextScreen: QRCodeGenerator(),
                      icon: Icons.qr_code_rounded,
                    ),
                    _buildToolCard(
                      title: AppConstants.deviceDetail,
                      nextScreen: DeviceInfoHomePage(),
                      icon: Icons.phone_android_rounded,
                    ),
                    _buildAddButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
