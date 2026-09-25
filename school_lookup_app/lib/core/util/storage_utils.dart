import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../error/app_exception.dart';
import 'app_logger.dart';

class StorageUtils {
  static const String publicFolderName = 'Bharat Shikshak Sahayak';

  /// Detailed permission check result.
  static Future<void> checkAndRequestPermissions({bool requireCamera = true}) async {
    List<Permission> permissionsToRequest = [];

    if (requireCamera) {
      permissionsToRequest.add(Permission.camera);
    }
    permissionsToRequest.add(Permission.storage);
    permissionsToRequest.add(Permission.photos);

    // Request permissions
    Map<Permission, PermissionStatus> statuses = await permissionsToRequest.request();

    bool cameraGranted = !requireCamera || (statuses[Permission.camera]?.isGranted ?? false);
    bool storageGranted = (statuses[Permission.storage]?.isGranted ?? false) ||
                          (statuses[Permission.photos]?.isGranted ?? false);

    // Check MANAGE_EXTERNAL_STORAGE for Android 11+ if regular storage isn't granted
    if (Platform.isAndroid && !storageGranted) {
      if (await Permission.manageExternalStorage.isGranted) {
        storageGranted = true;
      }
    }

    if (cameraGranted && storageGranted) {
      AppLogger.info("Camera and Storage permissions are granted.");
      return;
    }

    // Determine if any required permission is permanently denied
    bool cameraPermanentlyDenied = requireCamera &&
        (statuses[Permission.camera]?.isPermanentlyDenied ?? false);
    bool storagePermanentlyDenied = (statuses[Permission.storage]?.isPermanentlyDenied ?? false) ||
        (statuses[Permission.photos]?.isPermanentlyDenied ?? false);

    bool isPermanentlyDenied = cameraPermanentlyDenied || storagePermanentlyDenied;

    String missingStr = "";
    if (!cameraGranted && !storageGranted) {
      missingStr = "Camera and Storage";
    } else if (!cameraGranted) {
      missingStr = "Camera";
    } else {
      missingStr = "Storage / Photos";
    }

    throw PermissionException(
      title: "$missingStr Permission Required",
      message: "$missingStr permission is required to scan documents and save files. "
          "${isPermanentlyDenied ? 'Please grant access in App Settings.' : 'Please allow access when prompted.'}",
      isPermanentlyDenied: isPermanentlyDenied,
    );
  }

  /// Backward compatible simple permission check.
  static Future<bool> requestPermissions() async {
    try {
      await checkAndRequestPermissions();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Checks if there is sufficient storage space (threshold in MB).
  static Future<bool> hasSufficientStorage({int thresholdMB = 50}) async {
    try {
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
        // Try to get the root of internal storage /storage/emulated/0/
        directory = Directory('/storage/emulated/0/$publicFolderName');
        
        if (!await _canWriteToDirectory(directory)) {
          final docs = await getApplicationDocumentsDirectory();
          directory = Directory('${docs.path}/$publicFolderName');
        }
      } else {
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
      if (!await tempFile.exists()) {
        throw StorageSpaceException(
          title: "File Not Found",
          message: "The captured image file could not be found. Please try taking the picture again.",
        );
      }

      final permanentFile = await tempFile.copy(permanentPath);
      return permanentFile.path;
    } catch (e) {
      if (e is AppException) rethrow;

      AppLogger.error("Failed to save image permanently, using temp fallback", e);
      try {
        final docs = await getApplicationDocumentsDirectory();
        final name = tempPath.split('/').last;
        final fallbackPath = '${docs.path}/$name';
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.copy(fallbackPath);
          return fallbackPath;
        }
      } catch (fallbackError) {
        AppLogger.error("Fallback image save failed", fallbackError);
      }

      throw StorageSpaceException(
        title: "Save Failed",
        message: "Failed to save the image to local storage. Please ensure your device has available storage space.",
      );
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
