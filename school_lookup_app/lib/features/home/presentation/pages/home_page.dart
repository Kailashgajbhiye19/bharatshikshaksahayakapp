import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localization.dart';
import '../../../../features/history/presentation/providers/history_provider.dart';
import '../../../library/presentation/pages/library_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../scan/presentation/pages/scan_center_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../../features/sync/domain/services/sync_service.dart';

/// [HomePage] is the main navigation hub of the application.
/// It uses a [BottomNavigationBar] to switch between core features.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // --- Navigation State ---
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize pages only once.
    // _DashboardTab requires a callback to trigger navigation from within its context.
    _pages = [
      _DashboardTab(
        onScanTap: () => setState(() => _currentIndex = 2),
        onProfileTap: () => setState(() => _currentIndex = 4),
      ),
      const LibraryPage(),
      const ScanCenterPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    // Trigger monthly sync check on app load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider).performSyncIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      // --- Side Navigation Menu ---
      drawer: _buildSideDrawer(context, l10n),
      
      appBar: AppBar(
        title: const Text(
          'Bharat Shikshak Sahayak',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryOrange,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryOrange,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            onPressed: () => setState(() => _currentIndex = 4),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- Active Page ---
      body: _pages[_currentIndex],

      // --- Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.tr('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.menu_book), label: l10n.tr('library')),
          BottomNavigationBarItem(icon: const Icon(Icons.document_scanner), label: l10n.tr('scan')),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: l10n.tr('history')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.tr('profile')),
        ],
      ),
    );
  }

  Widget _buildSideDrawer(BuildContext context, AppLocalization l10n) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // -------------------------------------------------------------------
          // BACKEND INTEGRATION POINT: 
          // Bind teacher profile data (Name, Email, Image) from UserProvider.
          // -------------------------------------------------------------------
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryOrange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppColors.primaryOrange),
                ),
                const SizedBox(height: 10),
                Text(l10n.tr('teacher'), style: const TextStyle(color: Colors.white, fontSize: 18)),
                const Text('teacher@example.com', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(l10n.tr('home')),
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(l10n.tr('library')),
            onTap: () {
              setState(() => _currentIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.tr('history')),
            onTap: () {
              setState(() => _currentIndex = 3);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.tr('settings')),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.tr('logout')),
            onTap: () => _showLogoutDialog(context, l10n),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalization l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('logout')),
        content: Text(l10n.tr('logout_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.tr('cancel'))),
          TextButton(
            onPressed: () async {
              await Hive.box('settings').put('isLoggedIn', false);
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

/// [_DashboardTab] represents the home dashboard with quick actions and recent activity.
class _DashboardTab extends ConsumerWidget {
  final VoidCallback onScanTap;
  final VoidCallback onProfileTap;
  const _DashboardTab({required this.onScanTap, required this.onProfileTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    
    // -------------------------------------------------------------------------
    // BACKEND INTEGRATION POINT: 
    // Fetch actual recent activity from server or local DB.
    // Currently reading from local historyProvider.
    // -------------------------------------------------------------------------
    final recentScans = ref.watch(historyProvider).take(2).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeText(l10n),
            const SizedBox(height: 20),
            _buildHeroCard(l10n),
            const SizedBox(height: 20),
            _buildQuickActions(context, l10n),
            const SizedBox(height: 20),
            _AnalysisToolCard(l10n: l10n),
            const SizedBox(height: 20),
            _buildRecentActivityHeader(l10n),
            const SizedBox(height: 10),
            _buildRecentActivityList(context, l10n, recentScans),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText(AppLocalization l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${l10n.tr('namaste')}\n${l10n.tr('teacher')}",
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
        const SizedBox(height: 8),
        Text(l10n.tr('daily_overview'), style: const TextStyle(color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildHeroCard(AppLocalization l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primaryOrange,
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1580582932707-520aed937b7b'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.document_scanner, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(l10n.tr('scan_digitize'),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(l10n.tr('scan_desc'), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryOrange),
              onPressed: onScanTap,
              child: Text("${l10n.tr('start_scanning')}  →"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalization l10n) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: l10n.tr('morning_attendance'),
            subtitle: "Mark student presence",
            icon: Icons.assignment_turned_in,
            color: AppColors.primaryOrange,
            onTap: () => context.push('/attendance'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionCard(
            title: l10n.tr('class_schedule'),
            subtitle: l10n.tr('schedule_desc'),
            icon: Icons.calendar_today,
            color: AppColors.darkTeal,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Schedule feature coming in next update!")),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityHeader(AppLocalization l10n) {
    return Text(l10n.tr('recent_activity'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildRecentActivityList(BuildContext context, AppLocalization l10n, List dynamicScans) {
    if (dynamicScans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text(l10n.tr('no_recent_scans'), style: const TextStyle(color: Colors.grey))),
      );
    }
    return Column(
      children: dynamicScans.map((scan) => _RecentActivityTile(
        icon: Icons.document_scanner,
        title: scan.title,
        subtitle: "Scanned ${DateFormat('hh:mm a').format(scan.date)}",
        onTap: () => _showQuickPreview(context, scan),
      )).toList(),
    );
  }

  void _showQuickPreview(BuildContext context, dynamic scan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scan.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(DateFormat('MMMM dd, yyyy - hh:mm a').format(scan.date), style: const TextStyle(color: Colors.grey)),
                const Divider(height: 30),
                const Text("Content Extracted:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(scan.text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// --- Common UI Components for the Dashboard ---

class _ActionCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const _RecentActivityTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primaryOrange, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

class _AnalysisToolCard extends StatefulWidget {
  final AppLocalization l10n;
  const _AnalysisToolCard({required this.l10n});

  @override
  State<_AnalysisToolCard> createState() => _AnalysisToolCardState();
}

class _AnalysisToolCardState extends State<_AnalysisToolCard> {
  String? _selectedBook = "Class 8 Science (NCERT)";
  XFile? _selectedImage;

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _runAnalysis() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a photo from gallery first!")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate Image Processing & Comparison
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.primaryOrange),
              const SizedBox(width: 10),
              const Text("Analysis Result"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Topic verification completed!", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("The uploaded image has been compared with '$_selectedBook'."),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(8))),
                child: const Text(
                  "MATCH FOUND: 94% Similarity with Chapter 4 (Metals & Non-Metals).",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CLOSE"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Curriculum Matcher", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkTeal)),
            const SizedBox(height: 4),
            const Text("Upload notes to verify against curriculum", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Divider(height: 30),
            
            // 1. Dropdown for Book Selection
            const Text("Select Reference Book", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedBook,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              items: ["Class 8 Science (NCERT)", "Class 7 Mathematics", "Hindi Vyakaran"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBook = v),
            ),
            const SizedBox(height: 16),

            // 2. Gallery Picker
            InkWell(
              onTap: _pickFromGallery,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
                ),
                child: Column(
                  children: [
                    Icon(_selectedImage == null ? Icons.add_photo_alternate_outlined : Icons.check_circle, 
                        color: _selectedImage == null ? AppColors.primaryOrange : Colors.green, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      _selectedImage == null ? "Select Photo from Gallery" : "Image Selected: ${_selectedImage!.name}",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedImage == null ? Colors.black : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _runAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkTeal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("MATCH WITH BOOK CONTENT", style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
