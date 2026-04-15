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
}
