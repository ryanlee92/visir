import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../foundation/visir_tokens.dart';
import 'visir_component_role_themes.dart';
import 'visir_component_themes.dart';
import 'visir_text_theme.dart';

@immutable
class VisirThemeData {
  const VisirThemeData({
    required this.tokens,
    required this.components,
    required this.text,
  });

  final VisirTokens tokens;
  final VisirComponentThemes components;
  final VisirTextThemeData text;

  factory VisirThemeData.fallback() {
    final tokens = VisirTokens.fallback();
    const interaction = VisirControlInteractionThemeData(
      pressedScale: 0.96,
      pressedOpacity: 0.5,
      disabledOpacity: 0.45,
    );

    return VisirThemeData(
      tokens: tokens,
      text: VisirTextThemeData.fallback(tokens.colors),
      components: VisirComponentThemes(
        button: VisirButtonThemeData(
          glowBlur: 24,
          interaction: interaction,
          secondaryBackgroundColor: tokens.colors.surfaceOutline,
          secondaryHoverOverlayColor: tokens.colors.text.withValues(
            alpha: 0.08,
          ),
          secondaryForegroundColor: tokens.colors.text,
          ghostBackgroundColor: Colors.transparent,
          ghostHoverOverlayColor: tokens.colors.text.withValues(alpha: 0.03),
          ghostForegroundColor: tokens.colors.textMuted,
        ),
        control: VisirControlThemeData(
          sizing: VisirControlSizing(
            verticalPadding: const VisirControlSizeScale(sm: 6, md: 10, lg: 14),
            horizontalPadding: VisirControlSizeScale(
              sm: tokens.spacing.md.toDouble(),
              md: tokens.spacing.lg.toDouble(),
              lg: tokens.spacing.xl.toDouble(),
            ),
            iconSpacing: tokens.spacing.sm.toDouble(),
            compactSpacing: tokens.spacing.xs.toDouble(),
          ),
          borders: VisirBorderStates(
            base: VisirBorderState(
              color: tokens.colors.surfaceOutline,
              width: 1,
            ),
            hover: VisirBorderState(
              color: tokens.colors.surfaceOutline,
              width: 1,
            ),
            focus: VisirBorderState(color: tokens.colors.accent, width: 2),
            disabled: VisirBorderState(
              color: tokens.colors.surfaceOutline.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          radius: tokens.radius.md,
          interaction: interaction,
        ),
        surface: VisirSurfaceThemeData(
          padding: VisirSurfaceDensityScale(
            compact: tokens.spacing.md.toDouble(),
            comfortable: tokens.spacing.lg.toDouble(),
            spacious: tokens.spacing.xl.toDouble(),
          ),
          radius: tokens.radius.lg,
          borders: VisirBorderStates(
            base: VisirBorderState(
              color: tokens.colors.surfaceOutline,
              width: 1,
            ),
            hover: VisirBorderState(
              color: tokens.colors.surfaceOutline,
              width: 1,
            ),
            focus: VisirBorderState(color: tokens.colors.accent, width: 2),
            disabled: VisirBorderState(
              color: tokens.colors.surfaceOutline.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          elevation: const VisirSurfaceElevation(
            baseBlur: 18,
            baseOffsetY: 12,
            baseOpacity: 0.18,
            focusBlur: 20,
            focusSpread: 1,
            focusOpacity: 0.3,
          ),
        ),
        content: VisirContentThemeData(
          paddingHorizontal: 10,
          paddingVertical: 6,
          radius: 999,
          inlineSpacing: tokens.spacing.sm.toDouble(),
          compactSpacing: tokens.spacing.xs.toDouble(),
        ),
        feedback: const VisirFeedbackThemeData(
          size: VisirFeedbackSizeScale(sm: 12, md: 16, lg: 20),
          strokeWidth: 2,
          emphasisMuted: 0.6,
          emphasisStrong: 1,
        ),
      ),
    );
  }

  VisirThemeData copyWith({
    VisirTokens? tokens,
    VisirComponentThemes? components,
    VisirTextThemeData? text,
  }) {
    return VisirThemeData(
      tokens: tokens ?? this.tokens,
      components: components ?? this.components,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirThemeData &&
            tokens == other.tokens &&
            components == other.components &&
            text == other.text;
  }

  @override
  int get hashCode => Object.hash(tokens, components, text);
}
