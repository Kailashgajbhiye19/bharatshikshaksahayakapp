import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'app_logger.dart';

class StorageUtils {
  static const String publicFolderName = 'Bharat Shikshak Sahayak';

  /// Requests necessary permissions for scanning and storage.
  static Future<bool> requestPermissions() async {
    // 1. Basic Camera and Storage permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();

    bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    
    // 2. Advanced Storage Permission for Android 11+ (MANAGE_EXTERNAL_STORAGE)
    // This is required to create a folder at the root of internal storage.
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.isGranted) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          AppLogger.warning("MANAGE_EXTERNAL_STORAGE permission denied.");
          // We can still proceed if Permission.storage is granted, but folder creation might fail at root.
        }
      }
    }

    bool storageGranted = (statuses[Permission.storage]?.isGranted ?? false) || 
                          (statuses[Permission.photos]?.isGranted ?? false) ||
                          (Platform.isAndroid && await Permission.manageExternalStorage.isGranted);

    AppLogger.info("Permissions status: Camera: $cameraGranted, Storage: $storageGranted");
    
    return cameraGranted && storageGranted;
  }

  /// Checks if there is sufficient storage space (threshold in MB).
  static Future<bool> hasSufficientStorage({int thresholdMB = 50}) async {
    try {
      // In a real app, we'd use a package like 'disk_space_2' or similar to check disk space.
      return true; 
    } catch (e) {
      AppLogger.error("Error checking storage space", e);
      return false;
    }
  }

  /// Copies a file to a permanent location in the public "Bharat Shikshak Sahayak" folder.
  static Future<String> saveImagePermanently(String tempPath) async {
    Directory? directory;

    try {
      if (Platform.isAndroid) {
        // Try to get the root of internal storage
        // /storage/emulated/0/
        directory = Directory('/storage/emulated/0/$publicFolderName');
        
        // Check if we can write to this directory. If not, fallback to internal app storage.
        if (!await _canWriteToDirectory(directory)) {
          final docs = await getApplicationDocumentsDirectory();
          directory = Directory('${docs.path}/$publicFolderName');
        }
      } else {
        // Fallback for iOS/other platforms
        final docs = await getApplicationDocumentsDirectory();
        directory = Directory('${docs.path}/$publicFolderName');
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
        AppLogger.info("Created folder: ${directory.path}");
      }

      final name = tempPath.split('/').last;
      final permanentPath = '${directory.path}/$name';
      
      final tempFile = File(tempPath);
      final permanentFile = await tempFile.copy(permanentPath);
      
      return permanentFile.path;
    } catch (e) {
      AppLogger.error("Failed to save image permanently, using temp path", e);
      // Fallback to internal app storage if public folder fails
      final docs = await getApplicationDocumentsDirectory();
      final name = tempPath.split('/').last;
      final fallbackPath = '${docs.path}/$name';
      await File(tempPath).copy(fallbackPath);
      return fallbackPath;
    }
  }

  static Future<bool> _canWriteToDirectory(Directory dir) async {
    try {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final testFile = File('${dir.path}/.test_write');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}
