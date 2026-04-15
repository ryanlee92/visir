import 'package:flutter/foundation.dart';

@immutable
class VisirRadius {
  const VisirRadius({
    required this.sm,
    required this.md,
    required this.lg,
    required this.pill,
  });

  final double sm;
  final double md;
  final double lg;
  final double pill;
}
