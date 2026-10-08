import 'package:flutter/material.dart';

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
}
