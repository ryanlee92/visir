import 'package:flutter/material.dart';

import 'visir_component_role_themes.dart';

@immutable
class VisirButtonThemeData {
  const VisirButtonThemeData({
    required this.glowBlur,
    required this.interaction,
  });

  final double glowBlur;
  final VisirControlInteractionThemeData interaction;

  double get pressedScale => interaction.pressedScale;
  double get pressedOpacity => interaction.pressedOpacity;
  double get disabledOpacity => interaction.disabledOpacity;

  VisirButtonThemeData copyWith({
    double? glowBlur,
    VisirControlInteractionThemeData? interaction,
  }) {
    return VisirButtonThemeData(
      glowBlur: glowBlur ?? this.glowBlur,
      interaction: interaction ?? this.interaction,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirButtonThemeData &&
            glowBlur == other.glowBlur &&
            interaction == other.interaction;
  }

  @override
  int get hashCode => Object.hash(glowBlur, interaction);
}

@immutable
class VisirComponentThemes {
  factory VisirComponentThemes({
    required VisirButtonThemeData button,
    required VisirControlThemeData control,
    required VisirSurfaceThemeData surface,
    required VisirContentThemeData content,
    required VisirFeedbackThemeData feedback,
  }) {
    final normalizedButton = button.copyWith(interaction: control.interaction);

    return VisirComponentThemes._raw(
      button: normalizedButton,
      control: control,
      surface: surface,
      content: content,
      feedback: feedback,
    );
  }

  const VisirComponentThemes._raw({
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
    final resolvedControl = control ?? this.control;
    final resolvedButton = (button ?? this.button).copyWith(
      interaction: resolvedControl.interaction,
    );

    return VisirComponentThemes._raw(
      button: resolvedButton,
      control: resolvedControl,
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
  int get hashCode => Object.hash(button, control, surface, content, feedback);
}
