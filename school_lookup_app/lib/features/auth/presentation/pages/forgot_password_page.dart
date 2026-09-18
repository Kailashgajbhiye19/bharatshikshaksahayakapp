import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

/// [ForgotPasswordPage] helps users recover access to their account.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handles sending the reset link.
  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // -------------------------------------------------------------------------
    // BACKEND INTEGRATION POINT:
    // Call your AuthRepository to send a recovery email.
    // Example: await ref.read(authProvider.notifier).resetPassword(_emailController.text);
    // -------------------------------------------------------------------------

    await Future.delayed(const Duration(seconds: 1)); // Simulation

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link sent to your email!"),
          backgroundColor: AppColors.darkTeal,
        ),
      );
      context.go('/login');
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
                        _buildHeaderText(),
                        const SizedBox(height: 30),

                        // --- Input Field ---
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Teacher ID / Email",
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? "Enter your email" : null,
                        ),

                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                        
                        const SizedBox(height: 16),
                        _buildBackToLoginLink(),
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
      child: const Icon(Icons.lock_reset, color: Colors.white, size: 40),
    );
  }

  Widget _buildHeaderText() {
    return const Column(
      children: [
        Text("Reset Password", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
        SizedBox(height: 8),
        Text("Enter your email to receive a reset link", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleReset,
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("Send Reset Link  →"),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return TextButton(
      onPressed: () => context.go('/login'),
      child: const Text("Back to Login", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
    );
  }
}
