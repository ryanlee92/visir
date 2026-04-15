import 'package:flutter/material.dart';

import 'visir_colors.dart';
import 'visir_motion.dart';
import 'visir_radius.dart';
import 'visir_spacing.dart';

@immutable
class VisirTokens {
  const VisirTokens({
    required this.colors,
    required this.spacing,
    required this.radius,
    required this.motion,
  });

  final VisirColors colors;
  final VisirSpacing spacing;
  final VisirRadius radius;
  final VisirMotion motion;

  factory VisirTokens.fallback() {
    return VisirTokens(
      colors: const VisirColors(
        accent: Color(0xFF7C5DFF),
        accentStrong: Color(0xFF5A3FD7),
        surface: Color(0xCC1F1B33),
        surfaceMuted: Color(0x9927253F),
        surfaceOutline: Color(0x33FFFFFF),
        text: Color(0xFFF8F7FF),
        textMuted: Color(0xCCDBD7F3),
        textInverse: Color(0xFF110F1C),
        danger: Color(0xFFD94B67),
        success: Color(0xFF3BB273),
        warning: Color(0xFFF2A93B),
      ),
      spacing: const VisirSpacing(xs: 4, sm: 8, md: 12, lg: 16, xl: 24),
      radius: const VisirRadius(sm: 12, md: 16, lg: 22, pill: 999),
      motion: const VisirMotion(
        fast: Duration(milliseconds: 120),
        normal: Duration(milliseconds: 180),
        emphasized: Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
