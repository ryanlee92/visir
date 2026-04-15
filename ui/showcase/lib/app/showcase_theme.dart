import 'package:flutter/material.dart';

class ShowcaseTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        background: Color(0xFFF6F0E8),
        surface: Color(0xFFF6F0E8),
        onBackground: Color(0xFF17161A),
        onSurface: Color(0xFF17161A),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F0E8),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFF17161A),
        displayColor: const Color(0xFF17161A),
      ),
    );
  }
}
