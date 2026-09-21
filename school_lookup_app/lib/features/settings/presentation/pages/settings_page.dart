import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localization.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('settings')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Appearance"),
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark theme for the app"),
            value: settings.isDarkMode,
            activeThumbColor: AppColors.primaryOrange,
            onChanged: (val) => ref.read(settingsProvider.notifier).toggleDarkMode(val),
          ),
          const Divider(),
          _buildSectionHeader("Notifications"),
          SwitchListTile(
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive updates about curriculum changes"),
            value: settings.notificationsEnabled,
            activeThumbColor: AppColors.primaryOrange,
            onChanged: (val) => ref.read(settingsProvider.notifier).toggleNotifications(val),
          ),
          const Divider(),
          _buildSectionHeader("Language"),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primaryOrange),
            title: Text(l10n.tr('language')),
            subtitle: Text(settings.language == 'hi' ? 'हिन्दी' : settings.language == 'hinglish' ? 'Hinglish' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation to language selection or show a dialog
              _showLanguageDialog(context, ref, settings.language);
            },
          ),
          const Divider(),
          _buildSectionHeader("About"),
          const ListTile(
            title: Text("App Version"),
            trailing: Text("1.0.0+1"),
          ),
          ListTile(
            title: const Text("Privacy Policy"),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _langOption(context, ref, "English", "en", current == "en"),
            _langOption(context, ref, "हिन्दी", "hi", current == "hi"),
            _langOption(context, ref, "Hinglish", "hinglish", current == "hinglish"),
          ],
        ),
      ),
    );
  }

  Widget _langOption(BuildContext context, WidgetRef ref, String label, String code, bool isSelected) {
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        ref.read(settingsProvider.notifier).updateLanguage(code);
        ref.read(localeProvider.notifier).state = code;
        Navigator.pop(context);
      },
    );
  }
}
