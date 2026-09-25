import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

import '../../domain/models/scan_result.dart';
import '../../data/repositories/scan_repository.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../../core/util/storage_utils.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/util/app_logger.dart';

final scanServiceProvider = Provider((ref) => ScanService(ref));

/// [ScanService] handles capturing and processing images.
/// Uses [ImagePicker] for capture and [Google ML Kit] for OCR.
class ScanService {
  final Ref _ref;
  final _picker = ImagePicker();
  
  // Initialize OCR engine with Latin script support.
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  ScanService(this._ref);

  /// Captures or picks an image after verifying permissions and storage.
  Future<XFile?> pickImage({required ImageSource source}) async {
    // 1. Check & Request Permissions
    await StorageUtils.checkAndRequestPermissions(
      requireCamera: source == ImageSource.camera,
    );

    // 2. Check Storage Space
    final hasSpace = await StorageUtils.hasSufficientStorage();
    if (!hasSpace) {
      throw StorageSpaceException();
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Optimize size and quality
      );
      return image;
    } catch (e) {
      AppLogger.error("ImagePicker error", e);
      if (e is AppException) rethrow;
      throw CameraException(
        message: "Failed to open ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please try again.",
      );
    }
  }

  /// Processes the captured image and saves it permanently.
  Future<ScanResult> processAndSave(String title, String tempImagePath) async {
    try {
      // 1. Move image to permanent storage
      final permanentPath = await StorageUtils.saveImagePermanently(tempImagePath);

      // 2. Process image with ML Kit OCR
      RecognizedText recognizedText;
      try {
        final inputImage = InputImage.fromFilePath(permanentPath);
        recognizedText = await _textRecognizer.processImage(inputImage);
      } catch (ocrError) {
        AppLogger.error("OCR processing error", ocrError);
        throw OcrException(
          message: "Unable to process text from image. The text might be unclear or blurry.",
        );
      }

      // 3. Get current user ID from settings
      final settings = Hive.box('settings');
      final userId = settings.get('employeeId') as String?;

      // 4. Create the data model
      final result = ScanResult(
        id: const Uuid().v4(),
        title: title,
        text: recognizedText.text.trim().isNotEmpty
            ? recognizedText.text
            : "No readable text detected in document.",
        date: DateTime.now(),
        imagePath: permanentPath,
        isSynced: false,
        userId: userId,
      );

      // 5. Save to local storage (Hive)
      await _ref.read(scanRepositoryProvider).saveScanResult(result);
      
      // 6. Refresh UI history list
      _ref.read(historyProvider.notifier).loadHistory();
      
      return result;
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error("Failed to process and save scan", e);
      throw AppException(
        title: "Processing Failed",
        message: "Could not process document. Please ensure the image is valid and try again.",
      );
    }
  }
}
