import 'package:flutter/material.dart';

@immutable
class VisirColors {
  const VisirColors({
    required this.accent,
    required this.accentStrong,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceOutline,
    required this.text,
    required this.textMuted,
    required this.textInverse,
    required this.danger,
    required this.success,
    required this.warning,
  });

  final Color accent;
  final Color accentStrong;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceOutline;
  final Color text;
  final Color textMuted;
  final Color textInverse;
  final Color danger;
  final Color success;
  final Color warning;

  VisirColors copyWith({
    Color? accent,
    Color? accentStrong,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceOutline,
    Color? text,
    Color? textMuted,
    Color? textInverse,
    Color? danger,
    Color? success,
    Color? warning,
  }) {
    return VisirColors(
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceOutline: surfaceOutline ?? this.surfaceOutline,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }
}
