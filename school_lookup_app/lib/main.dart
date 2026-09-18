import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/onboarding/presentation/pages/language_page.dart';
import 'features/onboarding/presentation/pages/splash_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/attendance/presentation/pages/attendance_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/library/presentation/pages/library_page.dart';
import 'features/scan/domain/models/scan_result.dart';
import 'features/scan/data/repositories/scan_repository.dart';
import 'core/util/app_logger.dart';

void main() async {
  // --- Global Error Handling for Production ---
  FlutterError.onError = (details) {
    AppLogger.error("Flutter Error: ${details.exception}", details.exception, details.stack);
  };

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(ScanResultAdapter());
    await Hive.openBox<ScanResult>(ScanRepository.boxName);
    await Hive.openBox('settings');
    AppLogger.info("Local storage initialized successfully.");
  } catch (e) {
    AppLogger.error("Local storage initialization failed.", e);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bharat Shikshak Sahayak',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const LanguagePage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/attendance',
      builder: (context, state) => const AttendancePage(),
    ),
    GoRoute(path: '/library', builder: (context, state) => const LibraryPage()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
  ],
);
