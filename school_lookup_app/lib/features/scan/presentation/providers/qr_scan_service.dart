import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/util/storage_utils.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/util/app_logger.dart';

final qrScanServiceProvider = Provider((ref) => QrScanService());

class QrScanService {
  final _picker = ImagePicker();
  final _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

  Future<String?> scanQr({required ImageSource source}) async {
    // 1. Permission check
    await StorageUtils.checkAndRequestPermissions(
      requireCamera: source == ImageSource.camera,
    );

    XFile? image;
    try {
      image = await _picker.pickImage(source: source);
    } catch (e) {
      AppLogger.error("Error picking image for QR scan", e);
      throw CameraException(
        message: "Unable to access ${source == ImageSource.camera ? 'camera' : 'gallery'} for QR scanning.",
      );
    }

    if (image == null) return null;

    List<Barcode> barcodes;
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      barcodes = await _barcodeScanner.processImage(inputImage);
    } catch (e) {
      AppLogger.error("Barcode processing error", e);
      throw QrScanException(
        message: "Failed to process image. Please try capturing a clearer picture of the QR code.",
      );
    }

    if (barcodes.isEmpty) {
      throw QrScanException(
        message: "No valid QR code was detected in the image. Please try again with clear lighting.",
      );
    }

    final String? code = barcodes.first.displayValue;
    
    if (code != null && code.isNotEmpty) {
      final Uri? url = Uri.tryParse(code);
      if (url != null && url.hasScheme && (url.scheme == 'http' || url.scheme == 'https')) {
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          AppLogger.error("Could not launch QR URL: $url", e);
        }
      }
    }

    return code;
  }

  void dispose() {
    _barcodeScanner.close();
  }
}
