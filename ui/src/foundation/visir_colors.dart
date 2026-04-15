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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirColors &&
            accent == other.accent &&
            accentStrong == other.accentStrong &&
            surface == other.surface &&
            surfaceMuted == other.surfaceMuted &&
            surfaceOutline == other.surfaceOutline &&
            text == other.text &&
            textMuted == other.textMuted &&
            textInverse == other.textInverse &&
            danger == other.danger &&
            success == other.success &&
            warning == other.warning;
  }

  @override
  int get hashCode => Object.hash(
    accent,
    accentStrong,
    surface,
    surfaceMuted,
    surfaceOutline,
    text,
    textMuted,
    textInverse,
    danger,
    success,
    warning,
  );
}
