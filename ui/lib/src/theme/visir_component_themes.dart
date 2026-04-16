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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirButtonThemeData &&
            glowBlur == other.glowBlur &&
            pressedScale == other.pressedScale &&
            disabledOpacity == other.disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(glowBlur, pressedScale, disabledOpacity);
}

@immutable
class VisirComponentThemes {
  const VisirComponentThemes({required this.button});

  final VisirButtonThemeData button;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirComponentThemes && button == other.button;
  }

  @override
  int get hashCode => button.hashCode;
}
