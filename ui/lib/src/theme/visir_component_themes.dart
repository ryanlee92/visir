import 'package:flutter/material.dart';

import 'visir_component_role_themes.dart';

@immutable
class VisirButtonThemeData {
  const VisirButtonThemeData({
    required this.glowBlur,
    required this.interaction,
    required this.secondaryBackgroundColor,
    required this.secondaryHoverOverlayColor,
    required this.secondaryForegroundColor,
    required this.ghostBackgroundColor,
    required this.ghostHoverOverlayColor,
    required this.ghostForegroundColor,
  });

  final double glowBlur;
  final VisirControlInteractionThemeData interaction;
  final Color secondaryBackgroundColor;
  final Color secondaryHoverOverlayColor;
  final Color secondaryForegroundColor;
  final Color ghostBackgroundColor;
  final Color ghostHoverOverlayColor;
  final Color ghostForegroundColor;

  double get pressedScale => interaction.pressedScale;
  double get pressedOpacity => interaction.pressedOpacity;
  double get disabledOpacity => interaction.disabledOpacity;

  VisirButtonThemeData copyWith({
    double? glowBlur,
    VisirControlInteractionThemeData? interaction,
    Color? secondaryBackgroundColor,
    Color? secondaryHoverOverlayColor,
    Color? secondaryForegroundColor,
    Color? ghostBackgroundColor,
    Color? ghostHoverOverlayColor,
    Color? ghostForegroundColor,
  }) {
    return VisirButtonThemeData(
      glowBlur: glowBlur ?? this.glowBlur,
      interaction: interaction ?? this.interaction,
      secondaryBackgroundColor:
          secondaryBackgroundColor ?? this.secondaryBackgroundColor,
      secondaryHoverOverlayColor:
          secondaryHoverOverlayColor ?? this.secondaryHoverOverlayColor,
      secondaryForegroundColor:
          secondaryForegroundColor ?? this.secondaryForegroundColor,
      ghostBackgroundColor: ghostBackgroundColor ?? this.ghostBackgroundColor,
      ghostHoverOverlayColor:
          ghostHoverOverlayColor ?? this.ghostHoverOverlayColor,
      ghostForegroundColor: ghostForegroundColor ?? this.ghostForegroundColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirButtonThemeData &&
            glowBlur == other.glowBlur &&
            interaction == other.interaction &&
            secondaryBackgroundColor == other.secondaryBackgroundColor &&
            secondaryHoverOverlayColor == other.secondaryHoverOverlayColor &&
            secondaryForegroundColor == other.secondaryForegroundColor &&
            ghostBackgroundColor == other.ghostBackgroundColor &&
            ghostHoverOverlayColor == other.ghostHoverOverlayColor &&
            ghostForegroundColor == other.ghostForegroundColor;
  }

  @override
  int get hashCode => Object.hash(
    glowBlur,
    interaction,
    secondaryBackgroundColor,
    secondaryHoverOverlayColor,
    secondaryForegroundColor,
    ghostBackgroundColor,
    ghostHoverOverlayColor,
    ghostForegroundColor,
  );
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
