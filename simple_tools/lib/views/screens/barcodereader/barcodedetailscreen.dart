import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BarcodeDetailsScreen extends StatelessWidget {
  final String barcode;

  BarcodeDetailsScreen({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Scanned Content: $barcode'),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    // Action for URLs
    if (Uri.tryParse(barcode)?.hasAbsolutePath ?? false) {
      buttons.add(ElevatedButton(
        onPressed: () async {
          final Uri url = Uri.parse(barcode);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        child: const Text('Open URL'),
      ));
    }

    // Action for email addresses
    if (barcode.contains('@')) {
      buttons.add(ElevatedButton(
        onPressed: () {
          final Uri emailUri = Uri(
            scheme: 'mailto',
            path: barcode,
          );
          launchUrl(emailUri.toString() as Uri);
        },
        child: const Text('Send Email'),
      ));
    }

    // Action for plain text (Copy to clipboard)
    buttons.add(ElevatedButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: barcode));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text copied to clipboard')),
        );
      },
      child: const Text('Copy Text'),
    ));

    return Column(children: buttons);
  }
}