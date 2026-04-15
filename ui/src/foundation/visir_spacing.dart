import 'package:flutter/foundation.dart';

@immutable
class VisirSpacing {
  const VisirSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
}
