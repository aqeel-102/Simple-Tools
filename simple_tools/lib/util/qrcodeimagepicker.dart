/*import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';


import 'history.dart';

class QRCodeImageHelper {
  final ImagePicker _picker = ImagePicker();

  Future<String?> scanQRCodeFromImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Use the mobile_scanner package to decode QR code from the image
        String? qrCode = await MobileScanner().scanFromPath(image.path);
        if (qrCode != null) {
          HistoryHelper.addToHistory(qrCode);
          return qrCode;
        } else {
          return 'No QR code found in the image';
        }
      } else {
        return 'No image selected';
      }
    } catch (e) {
      return 'Failed to scan QR code: $e';
    }
  }
}*/