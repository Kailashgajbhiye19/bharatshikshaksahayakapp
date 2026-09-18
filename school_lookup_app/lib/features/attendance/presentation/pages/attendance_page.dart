import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localization.dart';

/// [Student] represents a pupil in a classroom.
class Student {
  final String name;
  final int rollNo;
  String status; // "Present", "Absent", "Late"

  Student({required this.name, required this.rollNo, this.status = "Present"});
}

/// [AttendanceNotifier] manages the state of the attendance list.
class AttendanceNotifier extends StateNotifier<List<Student>> {
  AttendanceNotifier()
    : super([
        // ---------------------------------------------------------------------
        // BACKEND INTEGRATION POINT: 
        // Fetch actual student list for the selected class/section.
        // ---------------------------------------------------------------------
        Student(name: "Aarav Sharma", rollNo: 1),
        Student(name: "Diya Patel", rollNo: 2, status: "Absent"),
        Student(name: "Ishaan Kumar", rollNo: 3, status: "Late"),
        Student(name: "Neha Gupta", rollNo: 4),
      ]);

  /// Updates the attendance status of a specific student.
  void updateStatus(int index, String status) {
    state = [...state]..[index].status = status;
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<Student>>(
  (ref) => AttendanceNotifier(),
);

/// [AttendancePage] allows teachers to mark daily attendance for their students.
class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final students = ref.watch(attendanceProvider);
    
    // Calculate stats
    int present = students.where((s) => s.status == "Present").length;
    int absent = students.where((s) => s.status == "Absent").length;
    int late = students.where((s) => s.status == "Late").length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('morning_attendance')), centerTitle: true),
      body: Column(
        children: [
          // --- Stats Grid ---
          _buildStatsGrid(l10n, students.length, present, absent, late),
          
          // --- Search Bar ---
          _buildSearchBar(l10n),
          
          // --- Student List ---
          Expanded(child: _buildStudentList(ref, students, l10n)),
          
          // --- Submit Action ---
          _buildSubmitButton(context, l10n),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(AppLocalization l10n, int total, int present, int absent, int late) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: _StatCard(label: l10n.tr('total'), value: total.toString(), color: Colors.black, borderColor: AppColors.primaryOrange)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(label: l10n.tr('present'), value: present.toString(), color: AppColors.darkTeal, borderColor: AppColors.darkTeal)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(label: l10n.tr('absent'), value: absent.toString(), color: Colors.red, borderColor: Colors.red)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(label: l10n.tr('late'), value: late.toString(), color: Colors.orange, borderColor: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalization l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.tr('search_student'),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildStudentList(WidgetRef ref, List<Student> students, AppLocalization l10n) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(child: Text(student.name[0])),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${l10n.tr('roll_no')} ${student.rollNo.toString().padLeft(2, '0')}", 
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    ],
                  ),
                ),
                // --- Status Toggle Buttons ---
                _StatusButton(
                  label: l10n.tr('present'), color: AppColors.primaryOrange, 
                  isActive: student.status == "Present",
                  onTap: () => ref.read(attendanceProvider.notifier).updateStatus(index, "Present"),
                ),
                const SizedBox(width: 4),
                _StatusButton(
                  label: l10n.tr('absent'), color: Colors.red.shade400, 
                  isActive: student.status == "Absent",
                  onTap: () => ref.read(attendanceProvider.notifier).updateStatus(index, "Absent"),
                ),
                const SizedBox(width: 4),
                _StatusButton(
                  label: l10n.tr('late'), color: Colors.orange, 
                  isActive: student.status == "Late",
                  onTap: () => ref.read(attendanceProvider.notifier).updateStatus(index, "Late"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalization l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // -----------------------------------------------------------------
            // BACKEND INTEGRATION POINT: 
            // Send the marked attendance list to the server.
            // -----------------------------------------------------------------
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.tr('attendance_success'))));
          },
          icon: const Icon(Icons.send),
          label: Text(l10n.tr('submit_attendance')),
        ),
      ),
    );
  }
}

/// Helper card for displaying summary statistics.
class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color, borderColor;

  const _StatCard({required this.label, required this.value, required this.color, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

/// Custom button for marking attendance status.
class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusButton({required this.label, required this.color, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
