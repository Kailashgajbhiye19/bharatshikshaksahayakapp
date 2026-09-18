import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/scan_result.dart';

final scanRepositoryProvider = Provider((ref) => ScanRepository());

class ScanRepository {
  static const String boxName = 'scan_results';

  Future<void> saveScanResult(ScanResult result) async {
    final box = Hive.box<ScanResult>(boxName);
    await box.put(result.id, result);
    await _applyRetentionPolicy();
  }

  List<ScanResult> getScanHistory() {
    final box = Hive.box<ScanResult>(boxName);
    // Note: In a real app, you might want to call _applyRetentionPolicy periodically
    // or when the app starts. Here I'll do it on fetch for simplicity as requested.
    _applyRetentionPolicy();
    final results = box.values.toList();
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  Future<void> clearHistory() async {
    final box = Hive.box<ScanResult>(boxName);
    await box.clear();
  }

  Future<void> _applyRetentionPolicy() async {
    final box = Hive.box<ScanResult>(boxName);
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    final keysToDelete = box.keys.where((key) {
      final result = box.get(key);
      return result != null && result.date.isBefore(thirtyDaysAgo);
    }).toList();

    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }
}
