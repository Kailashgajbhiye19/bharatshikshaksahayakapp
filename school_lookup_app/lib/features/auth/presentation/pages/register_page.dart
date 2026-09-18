import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/ui_utils.dart';
import '../../domain/repositories/auth_repository.dart';

/// [RegisterPage] allows new teachers to join the platform.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  // --- UI State ---
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // --- Controllers ---
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _schoolNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles user registration.
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final failure = await ref.read(authRepositoryProvider).register(
      employeeId: _employeeIdController.text,
      fullName: _nameController.text,
      schoolName: _schoolNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (failure == null) {
        context.go('/home');
      } else {
        UIUtils.showErrorSnackBar(context, failure.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.creamBackground),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderIcon(),
                        const SizedBox(height: 20),
                        _buildTitleText(),
                        const SizedBox(height: 30),

                        // --- Name Field ---
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? "Enter your name" : null,
                        ),
                        const SizedBox(height: 16),

                        // The backend uses this unique value to identify the teacher.
                        TextFormField(
                          controller: _employeeIdController,
                          decoration: const InputDecoration(
                            labelText: "Teacher ID",
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          validator: (v) => (v == null || v.trim().length < 3) ? "Enter a valid teacher ID" : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _schoolNameController,
                          decoration: const InputDecoration(
                            labelText: "School Name",
                            prefixIcon: Icon(Icons.school_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          validator: (v) => (v == null || v.trim().length < 2) ? "Enter your school name" : null,
                        ),
                        const SizedBox(height: 16),

                        // --- Email/ID Field ---
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email Address",
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@')) ? "Enter a valid email" : null,
                        ),
                        const SizedBox(height: 16),

                        // --- Password Field ---
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? "Minimum 6 characters" : null,
                        ),
                        const SizedBox(height: 16),

                        // --- Confirm Password Field ---
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            prefixIcon: const Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          validator: (v) => v != _passwordController.text ? "Passwords do not match" : null,
                        ),

                        const SizedBox(height: 24),
                        _buildRegisterButton(),
                        
                        const SizedBox(height: 16),
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
      child: const Icon(Icons.person_add, color: Colors.white, size: 40),
    );
  }

  Widget _buildTitleText() {
    return const Column(
      children: [
        Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
        SizedBox(height: 8),
        Text("Join the teaching community", style: TextStyle(color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("Register  →"),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?", style: TextStyle(fontSize: 13)),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text("Login here", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}
