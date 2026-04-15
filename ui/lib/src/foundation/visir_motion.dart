import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

@immutable
class VisirMotion {
  const VisirMotion({
    required this.fast,
    required this.normal,
    required this.emphasized,
    required this.curve,
  });

  final Duration fast;
  final Duration normal;
  final Duration emphasized;
  final Curve curve;
}
