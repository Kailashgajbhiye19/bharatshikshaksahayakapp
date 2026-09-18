import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';

import '../../domain/models/scan_result.dart';
import '../../data/repositories/scan_repository.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../../core/util/storage_utils.dart';

final scanServiceProvider = Provider((ref) => ScanService(ref));

/// [ScanService] handles the technical aspects of capturing and processing images.
/// It uses [ImagePicker] for capture and [Google ML Kit] for OCR.
class ScanService {
  final Ref _ref;
  final _picker = ImagePicker();
  
  // Initialize OCR engine with Latin script support.
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  ScanService(this._ref);

  /// Just picks an image from the source.
  Future<XFile?> pickImage({required ImageSource source}) async {
    // 1. Check Permissions
    final hasPermission = await StorageUtils.requestPermissions();
    if (!hasPermission) {
      throw Exception("Storage and Camera permissions are required for scanning.");
    }

    // 2. Check Storage Space
    final hasSpace = await StorageUtils.hasSufficientStorage();
    if (!hasSpace) {
      throw Exception("Insufficient storage space on the device. Please clear some space.");
    }

    return await _picker.pickImage(source: source);
  }

  /// Processes the captured image and saves it permanently.
  Future<ScanResult> processAndSave(String title, String tempImagePath) async {
    // 1. Move image to permanent storage
    final permanentPath = await StorageUtils.saveImagePermanently(tempImagePath);

    // 2. Process image with ML Kit OCR
    final inputImage = InputImage.fromFilePath(permanentPath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    // 3. Get current user ID from settings
    final settings = Hive.box('settings');
    final userId = settings.get('employeeId') as String?;

    // 4. Create the data model
    final result = ScanResult(
      id: const Uuid().v4(),
      title: title,
      text: recognizedText.text,
      date: DateTime.now(),
      imagePath: permanentPath,
      isSynced: false,
      userId: userId,
    );

    // 5. Save to local storage (Hive)
    await _ref.read(scanRepositoryProvider).saveScanResult(result);
    
    // 6. Refresh the UI history list
    _ref.read(historyProvider.notifier).loadHistory();
    
    return result;
  }
}
