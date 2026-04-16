import 'package:flutter/material.dart';
import 'package:visir_ui/visir_ui.dart';

class ShowcaseTheme {
  static ThemeData build() {
    final visirTokens = VisirThemeData.fallback().tokens;
    final baseScheme = const ColorScheme.light(
      surface: Color(0xFFF8F2EA),
      onSurface: Color(0xFF1D1A1F),
      primary: Color(0xFF0E6B5D),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFCBE9E3),
      onPrimaryContainer: Color(0xFF053B31),
      secondary: Color(0xFF8F4A2F),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFBDDC9),
      onSecondaryContainer: Color(0xFF42210F),
      outline: Color(0xFF8D8680),
      outlineVariant: Color(0xFFD8CFC7),
      surfaceContainerHigh: Color(0xFFFFF8F1),
    );

    final base = ThemeData(useMaterial3: true, colorScheme: baseScheme);

    return base.copyWith(
      scaffoldBackgroundColor: base.colorScheme.surface,
      cardTheme: CardThemeData(
        color: base.colorScheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(visirTokens.radius.sm),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(visirTokens.radius.pill),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: base.colorScheme.onSurface,
        displayColor: base.colorScheme.onSurface,
      ),
    );
  }
}
