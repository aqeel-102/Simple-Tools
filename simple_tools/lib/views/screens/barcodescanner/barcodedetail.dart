import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../util/app_constants.dart';

class BarcodeDetailScreen extends StatelessWidget {
  final String barcodeData;

  const BarcodeDetailScreen({super.key, required this.barcodeData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Details'),
        backgroundColor: AppConstants.mainColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 94, 132, 198),
              const Color.fromARGB(255, 185, 201, 228).withOpacity(0.8),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          size: 50,
                          color: AppConstants.mainColor,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Scanned Content',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            barcodeData,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    // Action for URLs
    if (Uri.tryParse(barcodeData)?.hasAbsolutePath ?? false) {
      buttons.add(
        _buildButton(
          icon: Icons.open_in_browser,
          label: 'Open URL',
          onPressed: () async {
            final Uri url = Uri.parse(barcodeData);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
        ),
      );
      buttons.add(const SizedBox(height: 15));
    }

    // Action for email addresses
    if (barcodeData.contains('@')) {
      buttons.add(
        _buildButton(
          icon: Icons.email,
          label: 'Send Email',
          onPressed: () async {
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: barcodeData,
            );
            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            }
          },
        ),
      );
      buttons.add(const SizedBox(height: 15));
    }

    // Action for plain text (Copy to clipboard)
    buttons.add(
      _buildButton(
        icon: Icons.copy,
        label: 'Copy Text',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: barcodeData));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Copied to clipboard'),
              backgroundColor: AppConstants.mainColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );

    return Column(children: buttons);
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.mainColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
