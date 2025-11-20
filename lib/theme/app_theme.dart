import 'package:flutter/material.dart';

class AppTheme {

  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryContainer = Color(0xFFEDEBFF);
  static const Color onPrimaryContainer = Color(0xFF0B1026);

  static const Color secondary = Color(0xFF06B6D4);
  static const Color background = Color(0xFFF7F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6B7280);

  // Status colors
  static const Color statusNew = Color(0xFF4F46E5); // primary
  static const Color statusContacted = Color(0xFFF59E0B); // amber-500
  static const Color statusConverted = Color(0xFF10B981); // emerald-500
  static const Color statusLost = Color(0xFFEF4444); // red-500


  static const Color avatarBg = Color(0xFFEDEBFF);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(seedColor: primary).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
      surface: surface,
      onSurface: Colors.black,
      tertiary: muted,
      onTertiary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondaryContainer: Colors.white,
      onSecondaryContainer: Colors.black,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          secondary: secondary,
          onSecondary: Colors.black,
          error: Colors.red.shade300,
          onError: Colors.black,
          surface: Color(0xFF111827),
          onSurface: Colors.white,
          tertiary: muted,
          onTertiary: Colors.white,
          primaryContainer: Color(0xFF2E2B5F),
          onPrimaryContainer: Colors.white,
          secondaryContainer: Color(0xFF073440),
          onSecondaryContainer: Colors.white,
        );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }
}

// Convenience access to status colors
class AppStatusColors {
  static const Color newLead = AppTheme.statusNew;
  static const Color contacted = AppTheme.statusContacted;
  static const Color converted = AppTheme.statusConverted;
  static const Color lost = AppTheme.statusLost;
}
