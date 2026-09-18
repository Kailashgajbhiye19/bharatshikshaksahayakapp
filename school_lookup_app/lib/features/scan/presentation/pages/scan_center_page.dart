import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localization.dart';
import '../providers/scan_provider.dart';
import '../providers/qr_scan_service.dart';
import './scan_preview_page.dart';
import './scan_result_page.dart';

/// [ScanCenterPage] provides various digitization tools for teachers.
/// It supports OCR (Text Recognition) and QR Code scanning with live camera or gallery upload.
class ScanCenterPage extends ConsumerWidget {
  const ScanCenterPage({super.key});

  /// Displays a selection menu for image source (Camera vs Gallery).
  Future<ImageSource?> _showSourcePicker(BuildContext context, {bool cameraOnly = false}) async {
    if (cameraOnly) return ImageSource.camera;

    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Source", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceOption(
                    icon: Icons.camera_alt, label: "Camera",
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  _SourceOption(
                    icon: Icons.photo_library, label: "Gallery",
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Triggers the document/text scanning flow.
  Future<void> _handleScan(BuildContext context, WidgetRef ref, String title, {bool cameraOnly = false}) async {
    final source = await _showSourcePicker(context, cameraOnly: cameraOnly);
    if (source == null) return;

    bool needsScan = true;
    while (needsScan) {
      try {
        final service = ref.read(scanServiceProvider);
        
        // 1. Pick Image (includes permission and storage checks)
        final XFile? image = await service.pickImage(source: source);
        if (image == null) return;

        if (!context.mounted) return;

        // 2. Navigate to Preview
        final bool? confirmed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ScanPreviewPage(imagePath: image.path, title: title),
          ),
        );

        if (confirmed == true) {
          needsScan = false; // Exit loop and process
          
          // 3. Process and Save
          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
          }

          final result = await service.processAndSave(title, image.path);

          if (context.mounted) {
            Navigator.pop(context); // Close loading dialog
            
            // 4. Navigate to Result Page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanResultPage(result: result),
              ),
            );
          }
        } else if (confirmed == null) {
          // User backed out of preview page using system back button
          needsScan = false;
        }
        // If confirmed is false (Retake), loop continues and triggers camera again
      } catch (e) {
        needsScan = false;
        if (context.mounted) {
          _showErrorDialog(context, e.toString());
        }
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Action Required"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Triggers the QR code scanning and redirection flow.
  Future<void> _handleQrScan(BuildContext context, WidgetRef ref, AppLocalization l10n) async {
    final source = await _showSourcePicker(context);
    if (source == null) return;

    try {
      final code = await ref.read(qrScanServiceProvider).scanQr(source: source);
      if (code != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR Code Detected: $code')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('scan_center')), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- Scanning Options ---
              _buildScanOption(l10n.tr('digitize_textbook'), Icons.menu_book, AppColors.primaryOrange, 
                  () => _handleScan(context, ref, l10n.tr('digitize_textbook'))),
              const SizedBox(height: 16),
              _buildScanOption(l10n.tr('handwritten_notes'), Icons.edit_note, AppColors.darkTeal, 
                  () => _handleScan(context, ref, l10n.tr('handwritten_notes'))),
              const SizedBox(height: 16),
              _buildScanOption(l10n.tr('quick_id_scan'), Icons.badge, Colors.brown, 
                  () => _handleScan(context, ref, l10n.tr('quick_id_scan'), cameraOnly: true)),
              const SizedBox(height: 16),
              _buildScanOption(l10n.tr('qr_redirect'), Icons.qr_code_scanner, Colors.deepPurple, 
                  () => _handleQrScan(context, ref, l10n)),
              
              const SizedBox(height: 24),

              // --- Education/Tips Section ---
              _buildTipsCard(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return _ScanOptionCard(title: title, icon: icon, color: color, onTap: onTap);
  }

  Widget _buildTipsCard(AppLocalization l10n) {
    return Card(
      color: AppColors.lightOrange.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.primaryOrange),
                const SizedBox(width: 8),
                Text(l10n.tr('scanner_tips'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Text(l10n.tr('tip1')),
            Text(l10n.tr('tip2')),
            Text(l10n.tr('tip3')),
            Text(l10n.tr('tip4')),
          ],
        ),
      ),
    );
  }
}

/// Helper component for image source selection.
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.primaryOrange),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Branded card for scan tool selection.
class _ScanOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScanOptionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
