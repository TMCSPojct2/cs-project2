import 'package:flutter/material.dart';

class AppColors {
  static const Color ink = Color(0xFF1B2230);
  static const Color primary = Color(0xFF0F5B57);
  static const Color primaryDark = Color(0xFF0A3D3B);
  static const Color secondary = Color(0xFFB38A3D);
  static const Color sand = Color(0xFFF3EAD8);
  static const Color mist = Color(0xFFF4F6F8);
  static const Color background = Color(0xFFF7F8FA);
  static const Color card = Colors.white;
  static const Color line = Color(0xFFE2E7EC);
  static const Color muted = Color(0xFF667085);
  static const Color success = Color(0xFF1D8A59);
  static const Color warning = Color(0xFFB76E12);
  static const Color danger = Color(0xFFC53A3A);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    const arabicFallback = ['Noto Naskh Arabic', 'Noto Sans Arabic', 'Amiri'];

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(fontSize: 48, height: 1.02, fontWeight: FontWeight.w800, color: AppColors.ink, fontFamilyFallback: arabicFallback),
        headlineLarge: const TextStyle(fontSize: 36, height: 1.08, fontWeight: FontWeight.w800, color: AppColors.ink, fontFamilyFallback: arabicFallback),
        headlineMedium: const TextStyle(fontSize: 28, height: 1.12, fontWeight: FontWeight.w800, color: AppColors.ink, fontFamilyFallback: arabicFallback),
        titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamilyFallback: arabicFallback),
        titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamilyFallback: arabicFallback),
        bodyLarge: const TextStyle(fontSize: 16, height: 1.55, fontWeight: FontWeight.w500, color: AppColors.ink, fontFamilyFallback: arabicFallback),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, color: AppColors.muted, fontFamilyFallback: arabicFallback),
        labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamilyFallback: arabicFallback),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.line),
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
