import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_lookup_app/features/scan/domain/models/scan_result.dart';
import 'package:school_lookup_app/features/scan/data/repositories/scan_repository.dart';
import '../../../../core/util/app_logger.dart';

final syncServiceProvider = Provider((ref) => SyncService(ref));

class SyncService {
  final Ref _ref;
  
  SyncService(this._ref);

  /// Checks and performs synchronization if needed and possible.
  Future<void> performSyncIfNeeded() async {
    final settings = Hive.box('settings');
    final lastSyncStr = settings.get('lastSyncDate') as String?;
    final lastSyncDate = lastSyncStr != null ? DateTime.tryParse(lastSyncStr) : null;
    
    final now = DateTime.now();
    
    // Check if 30 days have passed since last sync
    if (lastSyncDate != null && now.difference(lastSyncDate).inDays < 30) {
      AppLogger.info("Sync not required yet. Last sync was on $lastSyncDate");
      return;
    }

    // Check internet connection
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      AppLogger.info("Sync required but no internet connection available.");
      return;
    }

    AppLogger.info("Starting monthly sync...");
    await _syncData();
    
    // Update last sync date
    await settings.put('lastSyncDate', now.toIso8601String());
  }

  Future<void> _syncData() async {
    try {
      final repository = _ref.read(scanRepositoryProvider);
      final allScans = repository.getScanHistory();
      final unsyncedScans = allScans.where((scan) => scan.isSynced != true).toList();

      if (unsyncedScans.isEmpty) {
        AppLogger.info("No new data to sync.");
        return;
      }

      for (final scan in unsyncedScans) {
        await _uploadScan(scan);
      }
      
      AppLogger.info("Monthly sync completed successfully.");
    } catch (e) {
      AppLogger.error("Error during sync", e);
    }
  }

  Future<void> _uploadScan(ScanResult scan) async {
    try {
      // Simulation of upload. In reality, you'd use Dio to post data.
      // await ApiClient.instance.post('/scans/upload', data: { ... });
      
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
      
      // Update local status
      scan.isSynced = true;
      await scan.save();
      
      AppLogger.info("Synced scan: ${scan.id}");
    } catch (e) {
      AppLogger.error("Failed to upload scan ${scan.id}", e);
    }
  }
}
