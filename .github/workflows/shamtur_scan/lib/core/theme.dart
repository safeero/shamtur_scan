import 'package:flutter/material.dart';

class ShamturTheme {
  // الألوان الأساسية للهوية البصرية (Holographic Dark Theme)
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color secondaryGreen = Color(0xFF00F59B);
  static const Color darkBackground = Color(0xFF050B14);
  static const Color cardBackground = Color(0xFF0A192F);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8892B0);
  static const Color alertRed = Color(0xFFFF3366);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: secondaryGreen,
        surface: cardBackground,
        error: alertRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryCyan,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryCyan.withOpacity(0.2), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: darkBackground,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}