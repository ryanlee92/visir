import 'package:flutter/material.dart';

class ShowcaseTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFF6F0E8),
        onSurface: Color(0xFF17161A),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: base.colorScheme.surface,
      textTheme: base.textTheme.apply(
        bodyColor: base.colorScheme.onSurface,
        displayColor: base.colorScheme.onSurface,
      ),
    );
  }
}
