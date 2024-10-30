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
        title: const Text(AppConstants.barcodeReaderTitle),
        backgroundColor: AppConstants.mainColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scanned Content: $barcodeData',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    // Action for URLs
    if (Uri.tryParse(barcodeData)?.hasAbsolutePath ?? false) {
      buttons.add(ElevatedButton(
        onPressed: () async {
          final Uri url = Uri.parse(barcodeData);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        child: const Text('Open URL'),
      ));
    }

    // Action for email addresses
    if (barcodeData.contains('@')) {
      buttons.add(ElevatedButton(
        onPressed: () {
          final Uri emailUri = Uri(
            scheme: 'mailto',
            path: barcodeData,
          );
          launchUrl(emailUri);
        },
        child: const Text('Send Email'),
      ));
    }

    // Action for plain text (Copy to clipboard)
    buttons.add(ElevatedButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: barcodeData));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppConstants.copy)),
        );
      },
      child: const Text('Copy Text'),
    ));

    return Column(children: buttons);
  }
}
