import 'package:hive/hive.dart';
import '../../domain/models/app_settings.dart';

class SettingsRepository {
  final Box _box;
  SettingsRepository(this._box);

  AppSettings getSettings() {
    return AppSettings(
      language: _box.get('language', defaultValue: 'en'),
      isDarkMode: _box.get('isDarkMode', defaultValue: false),
      notificationsEnabled: _box.get('notificationsEnabled', defaultValue: true),
    );
  }

  Future<void> updateLanguage(String language) async {
    await _box.put('language', language);
  }

  Future<void> updateDarkMode(bool isDarkMode) async {
    await _box.put('isDarkMode', isDarkMode);
  }

  Future<void> updateNotifications(bool enabled) async {
    await _box.put('notificationsEnabled', enabled);
  }
}
