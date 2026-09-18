import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hive/hive.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/util/ui_utils.dart';
import '../../../../core/util/app_logger.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // --- UI State ---
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  
  // --- Controllers ---
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  void _loadRememberedUser() {
    final settingsBox = Hive.box('settings');
    final bool rememberMe = settingsBox.get('rememberMe', defaultValue: false);
    if (rememberMe) {
      final String? savedId = settingsBox.get('rememberedId');
      if (savedId != null) {
        setState(() {
          _rememberMe = true;
          _idController.text = savedId;
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    AppLogger.info("Attempting login for: ${_idController.text}");

    // Call Repository
    final failure = await ref.read(authRepositoryProvider).login(
      identifier: _idController.text,
      password: _passwordController.text
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (failure == null) {
        AppLogger.info("Login successful");
        
        // Save Remember Me preference
        final settingsBox = Hive.box('settings');
        await settingsBox.put('rememberMe', _rememberMe);
        if (_rememberMe) {
          await settingsBox.put('rememberedId', _idController.text);
        } else {
          await settingsBox.delete('rememberedId');
        }

        if (!mounted) return;
        context.go('/home');
      } else {
        AppLogger.warning("Login failed: ${failure.message}");
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
                        _buildLogo(),
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildFormFields(),
                        const SizedBox(height: 8),
                        _buildActionRow(),
                        const SizedBox(height: 24),
                        _buildLoginButton(),
                        const SizedBox(height: 16),
                        _buildFooter(),
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

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.primaryOrange, shape: BoxShape.circle),
      child: const Icon(Icons.school, color: Colors.white, size: 40),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          "Bharat Shikshak\nSahayak",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),
        ),
        SizedBox(height: 8),
        Text("Your Smart Teaching Companion", style: TextStyle(color: AppColors.textGrey)),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _idController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: "Teacher ID or Email",
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          validator: (value) => (value == null || value.isEmpty) ? "Please enter your ID" : null,
        ),
        const SizedBox(height: 16),
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
          validator: (value) => (value == null || value.length < 6) ? "Password must be at least 6 characters" : null,
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        SizedBox(
          height: 24, width: 24,
          child: Checkbox(
            value: _rememberMe,
            activeColor: AppColors.darkTeal,
            onChanged: (v) => setState(() => _rememberMe = v!),
          ),
        ),
        const SizedBox(width: 8),
        const Text("Remember me", style: TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.w600, fontSize: 12)),
        const Spacer(),
        TextButton(
          onPressed: () => context.go('/forgot-password'),
          child: const Text("Forgot Password?", style: TextStyle(color: AppColors.darkTeal, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("Login to Dashboard  →"),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("New to the platform?", style: TextStyle(fontSize: 13)),
        TextButton(
          onPressed: () => context.go('/register'),
          child: const Text("Register here", style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}
