import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../domain/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository(Hive.box('settings')));

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> updateLanguage(String language) async {
    await _repository.updateLanguage(language);
    state = state.copyWith(language: language);
  }

  Future<void> toggleDarkMode(bool isDarkMode) async {
    await _repository.updateDarkMode(isDarkMode);
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  Future<void> toggleNotifications(bool enabled) async {
    await _repository.updateNotifications(enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }
}
