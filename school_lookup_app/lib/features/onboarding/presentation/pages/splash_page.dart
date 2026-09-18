import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.elasticOut)),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Remove native splash screen as soon as our Flutter app is ready
    FlutterNativeSplash.remove();

    // Ensure the widget tree is fully built before starting logic
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // 2. Minimum display time for the animation (2 seconds)
        await Future.delayed(const Duration(seconds: 2));

        // 3. Robust Navigation
        if (mounted) {
          final settings = Hive.box('settings');
          final language = settings.get('language');
          final isLoggedIn = settings.get('isLoggedIn', defaultValue: false);

          String targetRoute;
          if (isLoggedIn) {
            targetRoute = '/home';
          } else if (language != null) {
            targetRoute = '/login';
          } else {
            targetRoute = '/onboarding';
          }

          GoRouter.of(context).go(targetRoute);
        }
      } catch (e) {
        // If anything fails, fallback to login/onboarding
        if (mounted) {
          GoRouter.of(context).go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        color: AppColors.primaryOrange,
                        size: 72,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Bharat Shikshak",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      "Sahayak",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
