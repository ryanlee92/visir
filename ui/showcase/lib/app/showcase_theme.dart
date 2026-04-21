import 'package:flutter/material.dart';
import 'package:visir_ui/visir_ui.dart';

class ShowcaseTheme {
  static ThemeData build(VisirThemeData visirThemeData, Brightness brightness) {
    final visirTokens = visirThemeData.tokens;
    final baseScheme = switch (brightness) {
      Brightness.dark => const ColorScheme.dark(
        surface: Color(0xFF16141A),
        onSurface: Color(0xFFF6F2EC),
        primary: Color(0xFF7FE0CE),
        onPrimary: Color(0xFF0E2622),
        primaryContainer: Color(0xFF173D37),
        onPrimaryContainer: Color(0xFFC8F3EA),
        secondary: Color(0xFFF0B38C),
        onSecondary: Color(0xFF3A1D12),
        secondaryContainer: Color(0xFF4A281A),
        onSecondaryContainer: Color(0xFFFDE4D2),
        outline: Color(0xFF8E8580),
        outlineVariant: Color(0xFF4B4440),
        surfaceContainerHigh: Color(0xFF211E25),
        surfaceContainerHighest: Color(0xff000000),
      ),
      Brightness.light => const ColorScheme.light(
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
        surfaceContainerHighest: Color(0xffffffff),
      ),
    };

    final base = ThemeData(useMaterial3: true, colorScheme: baseScheme);
    final textTheme = _buildTextTheme(visirThemeData.text, base.colorScheme);

    return base.copyWith(
      scaffoldBackgroundColor: base.colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
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
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }
}

TextTheme _buildTextTheme(VisirTextThemeData text, ColorScheme colors) {
  final onSurface = colors.onSurface;

  return TextTheme(
    displayLarge: text.hero.copyWith(color: onSurface),
    displayMedium: text.hero.copyWith(color: onSurface),
    displaySmall: text.title.copyWith(color: onSurface),
    headlineLarge: text.hero.copyWith(color: onSurface),
    headlineMedium: text.title.copyWith(color: onSurface),
    headlineSmall: text.title.copyWith(color: onSurface),
    titleLarge: text.hero.copyWith(color: onSurface),
    titleMedium: text.title.copyWith(color: onSurface),
    titleSmall: text.body.copyWith(color: onSurface),
    bodyLarge: text.body.copyWith(color: onSurface),
    bodyMedium: text.body.copyWith(color: onSurface),
    bodySmall: text.caption.copyWith(color: onSurface),
    labelLarge: text.label.copyWith(color: onSurface),
    labelMedium: text.label.copyWith(color: onSurface),
    labelSmall: text.caption.copyWith(color: onSurface),
  );
}
