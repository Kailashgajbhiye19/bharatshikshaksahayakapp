import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:school_lookup_app/features/scan/domain/models/scan_result.dart';
import 'package:school_lookup_app/features/scan/data/repositories/scan_repository.dart';

final historyProvider = StateNotifierProvider<HistoryNotifier, List<ScanResult>>((ref) {
  return HistoryNotifier(ref.watch(scanRepositoryProvider));
});

/// [HistoryNotifier] manages the teacher's scan history and synchronization states.
class HistoryNotifier extends StateNotifier<List<ScanResult>> {
  final ScanRepository _repository;

  HistoryNotifier(this._repository) : super([]) {
    loadHistory();
  }

  /// Loads the latest scan records from local storage.
  void loadHistory() {
    state = _repository.getScanHistory();
  }

  /// --------------------------------------------------------------------------
  /// BACKEND INTEGRATION POINT: 
  /// Implement the actual logic to upload documents to your cloud storage.
  /// --------------------------------------------------------------------------
  Future<void> clearAllLocalData() async {
    // This removes data from local Hive DB after user confirms successful upload.
    await _repository.clearHistory();
    loadHistory();
  }
}
