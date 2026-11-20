import 'package:flutter/material.dart';

/// Centralized color palette and Material 3 theme configuration for the Subway ordering app.
class AppTheme {
  // Brand Colors
  static const Color subwayGreen = Color(0xFF008C15);
  static const Color subwayYellow = Color(0xFFFFC600);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF111827);
  static const Color errorRed = Color(0xFFDC2626);

  /// Returns the light ThemeData used across the application.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: subwayGreen,
        onPrimary: Colors.white,
        secondary: subwayYellow,
        onSecondary: textDark,
        error: errorRed,
        onError: Colors.white,
        surface: surfaceWhite,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: subwayGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderGray, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: subwayGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: subwayYellow,
        foregroundColor: textDark,
      ),
    );
  }
}