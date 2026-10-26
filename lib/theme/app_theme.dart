import 'package:flutter/material.dart';

<<<<<<< HEAD
abstract final class AppTheme {
	static const Color _seedColor = Color(0xFF567A62);
	static const Color _surfaceColor = Color(0xFFF4F6F3);

	static ThemeData get light {
		final colorScheme = ColorScheme.fromSeed(
			seedColor: _seedColor,
			surface: _surfaceColor,
		);

		return ThemeData(
			colorScheme: colorScheme,
			scaffoldBackgroundColor: _surfaceColor,
			useMaterial3: true,
			appBarTheme: const AppBarTheme(
				backgroundColor: Colors.transparent,
				surfaceTintColor: Colors.transparent,
			),
			cardTheme: CardThemeData(
				color: colorScheme.surfaceContainerLowest,
				elevation: 0,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
			),
			inputDecorationTheme: InputDecorationTheme(
				filled: true,
				fillColor: colorScheme.surfaceContainerLowest,
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: BorderSide(color: colorScheme.outlineVariant),
				),
				enabledBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: BorderSide(color: colorScheme.outlineVariant),
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(12),
					borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
				),
			),
		);
	}
=======
/// Konfigurasi tema warna asli aplikasi Rencana Harian.
class AppTheme {
  AppTheme._();

  // Warna Asli Proyek (Indigo / Blue-Purple)
  static const Color primaryColor = Color(0xFF5B67CA);
  static const Color gradientStart = Color(0xFF6874D8);
  static const Color gradientEnd = Color(0xFF515DBE);

  // Background & Surface Asli
  static const Color lightBackground = Color(0xFFF7F7FC);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1A1C3D);
  static const Color lightTextSecondary = Color(0xFF757897);

  // Dark Mode disesuaikan dengan aksen Indigo asli
  static const Color darkBackground = Color(0xFF121324);
  static const Color darkSurface = Color(0xFF1D1F38);
  static const Color darkCard = Color(0xFF262847);
  static const Color darkTextPrimary = Color(0xFFF0F1FF);
  static const Color darkTextSecondary = Color(0xFFA5A8CD);

  /// Tema Terang (Tema Asli Aplikasi)
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: gradientStart,
      surface: lightSurface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: lightTextPrimary,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0.5,
        shadowColor: primaryColor.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  /// Tema Gelap (Disesuaikan dengan Aksen Indigo Asli)
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: const Color(0xFF8893FF),
      secondary: const Color(0xFFA5ADFF),
      surface: darkSurface,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: darkTextPrimary,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8893FF), width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6874D8),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }
>>>>>>> 76fb896d9e8ee4e99b2d6c302ebc9ebf2d3e47a9
}
