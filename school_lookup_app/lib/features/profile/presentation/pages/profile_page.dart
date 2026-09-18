import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// [ProfilePage] displays teacher account information and settings.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('profile')), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- User Header ---
            _buildProfileHeader(),
            const SizedBox(height: 32),
            
            // --- Contact Information ---
            // -----------------------------------------------------------------
            // BACKEND INTEGRATION POINT: 
            // Replace hardcoded values with data from UserProvider.
            // -----------------------------------------------------------------
            const _ProfileTile(icon: Icons.school_outlined, title: "Govt. Senior Secondary School", subtitle: "Jodhpur, Rajasthan"),
            const _ProfileTile(icon: Icons.email_outlined, title: "savita.sharma@edu.gov.in", subtitle: "Primary Email"),
            const _ProfileTile(icon: Icons.phone_android_outlined, title: "+91 98765 43210", subtitle: "Contact Number"),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // --- Settings & Preferences ---
            _buildSettingsList(context, l10n, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return const Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primaryOrange,
          child: Icon(Icons.person, color: Colors.white, size: 60),
        ),
        SizedBox(height: 16),
        Text("Mrs. Savita Sharma", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text("Senior Science Teacher", style: TextStyle(color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context, AppLocalization l10n, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.translate),
          title: Text(l10n.tr('language')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/onboarding'),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l10n.tr('settings')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Settings coming soon")),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text("Help & Support"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Help & Support coming soon")),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(l10n.tr('logout'), style: const TextStyle(color: Colors.red)),
          onTap: () => _showLogoutDialog(context, l10n, ref),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalization l10n, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('logout')),
        content: Text(l10n.tr('logout_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.tr('cancel'))),
          TextButton(
              onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            child: Text(l10n.tr('logout'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Helper component for profile data rows.
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;

  const _ProfileTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primaryOrange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }
}
