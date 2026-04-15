import 'package:flutter/material.dart';

@immutable
class VisirButtonThemeData {
  const VisirButtonThemeData({
    required this.glowBlur,
    required this.pressedScale,
    required this.disabledOpacity,
  });

  final double glowBlur;
  final double pressedScale;
  final double disabledOpacity;
}

@immutable
class VisirComponentThemes {
  const VisirComponentThemes({required this.button});

  final VisirButtonThemeData button;
}
