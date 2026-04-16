import 'package:flutter/material.dart';

import 'visir_component_role_themes.dart';

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

  VisirButtonThemeData copyWith({
    double? glowBlur,
    double? pressedScale,
    double? disabledOpacity,
  }) {
    return VisirButtonThemeData(
      glowBlur: glowBlur ?? this.glowBlur,
      pressedScale: pressedScale ?? this.pressedScale,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    );
  }

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
  const VisirComponentThemes({
    required this.button,
    required this.control,
    required this.surface,
    required this.content,
    required this.feedback,
  });

  final VisirButtonThemeData button;
  final VisirControlThemeData control;
  final VisirSurfaceThemeData surface;
  final VisirContentThemeData content;
  final VisirFeedbackThemeData feedback;

  VisirComponentThemes copyWith({
    VisirButtonThemeData? button,
    VisirControlThemeData? control,
    VisirSurfaceThemeData? surface,
    VisirContentThemeData? content,
    VisirFeedbackThemeData? feedback,
  }) {
    return VisirComponentThemes(
      button: button ?? this.button,
      control: control ?? this.control,
      surface: surface ?? this.surface,
      content: content ?? this.content,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirComponentThemes &&
            button == other.button &&
            control == other.control &&
            surface == other.surface &&
            content == other.content &&
            feedback == other.feedback;
  }

  @override
  int get hashCode =>
      Object.hash(button, control, surface, content, feedback);
}
