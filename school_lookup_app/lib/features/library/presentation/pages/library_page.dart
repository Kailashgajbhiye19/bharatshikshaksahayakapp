import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localization.dart';

/// [LibraryPage] is a digital repository for teaching materials and guides.
class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('teaching_resources')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Category Header ---
          _buildHeader(l10n.tr('my_subjects')),
          const SizedBox(height: 16),
          
          // --- Subject Folders ---
          _ResourceFolder(
            title: l10n.tr('class_8_science'),
            count: 12,
            color: AppColors.primaryOrange,
            itemsLabel: l10n.tr('items'),
          ),
          _ResourceFolder(
            title: l10n.tr('class_7_math'),
            count: 8,
            color: AppColors.darkTeal,
            itemsLabel: l10n.tr('items'),
          ),
          
          const SizedBox(height: 24),
          
          // --- Document List ---
          _buildHeader(l10n.tr('syllabus_guides')),
          const SizedBox(height: 16),
          _buildFileTile(l10n.tr('ncert_guide'), "PDF • 4.2 MB"),
          _buildFileTile(l10n.tr('math_lesson'), "PDF • 2.8 MB"),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildFileTile(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: IconButton(icon: const Icon(Icons.download), onPressed: () {}),
    );
  }
}

/// Helper component for categorized resources.
class _ResourceFolder extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final String itemsLabel;

  const _ResourceFolder({required this.title, required this.count, required this.color, required this.itemsLabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.folder, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$count $itemsLabel"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Opening $title details...")),
          );
        },
      ),
    );
  }
}
