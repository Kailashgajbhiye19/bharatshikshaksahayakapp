import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryOrange = Color(0xFFB83D12);
  static const Color lightOrange = Color(0xFFF9DFD0);
  static const Color darkTeal = Color(0xFF00636E);
  static const Color creamBackground = Color(0xFFFFF5EE);
  static const Color textDark = Color(0xFF2E2E2E);
  static const Color textGrey = Color(0xFFA3A3A3);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.creamBackground,
      primaryColor: AppColors.primaryOrange,
      colorScheme: ThemeData.light().colorScheme.copyWith(
        primary: AppColors.primaryOrange,
        secondary: AppColors.darkTeal,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }
}
