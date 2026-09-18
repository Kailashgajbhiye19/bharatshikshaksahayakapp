import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:url_launcher/url_launcher.dart';

final qrScanServiceProvider = Provider((ref) => QrScanService());

class QrScanService {
  final _picker = ImagePicker();
  final _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

  Future<String?> scanQr({required ImageSource source}) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;

    final inputImage = InputImage.fromFilePath(image.path);
    final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

    if (barcodes.isEmpty) {
      throw Exception("No QR code found in the selected image.");
    }

    final String? code = barcodes.first.displayValue;
    
    if (code != null) {
      final Uri? url = Uri.tryParse(code);
      if (url != null && await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }

    return code;
  }

  void dispose() {
    _barcodeScanner.close();
  }
}
