import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _idController;
  late TextEditingController _schoolController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameController = TextEditingController(text: profile.fullName);
    _emailController = TextEditingController(text: profile.email);
    _idController = TextEditingController(text: profile.employeeId);
    _schoolController = TextEditingController(text: profile.schoolName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = ref.read(profileProvider).copyWith(
        fullName: _nameController.text,
        email: _emailController.text,
        employeeId: _idController.text,
        schoolName: _schoolController.text,
      );
      ref.read(profileProvider.notifier).updateProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: const Icon(Icons.check, color: AppColors.primaryOrange),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePicker(),
              const SizedBox(height: 32),
              _buildTextField("Full Name", _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField("Email Address", _emailController, Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField("Teacher ID", _idController, Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildTextField("School Name", _schoolController, Icons.school_outlined),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("SAVE CHANGES"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primaryOrange,
            child: Icon(Icons.person, color: Colors.white, size: 60),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.darkTeal,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                onPressed: () {
                  // Integration with ImagePicker
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? "Field cannot be empty" : null,
    );
  }
}
