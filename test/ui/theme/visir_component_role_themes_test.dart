import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ui/visir_ui.dart';

void main() {
  test('VisirControlSizing exposes size accessors', () {
    const sizing = VisirControlSizing(
      height: VisirControlSizeScale(sm: 30, md: 40, lg: 50),
      horizontalPadding: VisirControlSizeScale(sm: 8, md: 12, lg: 16),
      iconSpacing: 6,
      compactSpacing: 4,
    );

    expect(sizing.heightFor(VisirButtonSize.sm), 30);
    expect(sizing.heightFor(VisirButtonSize.lg), 50);
    expect(sizing.horizontalPaddingFor(VisirButtonSize.md), 12);
    expect(sizing.iconSpacing, 6);
    expect(sizing.compactSpacing, 4);
  });

  test('VisirBorderStates copyWith updates only requested state', () {
    const base = VisirBorderState(color: Colors.white, width: 1);
    const hover = VisirBorderState(color: Colors.red, width: 1);
    const focus = VisirBorderState(color: Colors.blue, width: 2);
    const disabled = VisirBorderState(color: Colors.grey, width: 1);

    const states = VisirBorderStates(
      base: base,
      hover: hover,
      focus: focus,
      disabled: disabled,
    );

    final updated = states.copyWith(hover: hover.copyWith(width: 3));

    expect(updated, isNot(states));
    expect(updated.base, base);
    expect(updated.focus, focus);
    expect(updated.disabled, disabled);
    expect(updated.hover.width, 3);
  });

  test(
    'VisirControlThemeData copyWith preserves values and updates equality',
    () {
      const interaction = VisirControlInteractionThemeData(
        pressedScale: 0.96,
        pressedOpacity: 0.5,
        disabledOpacity: 0.45,
      );
      const control = VisirControlThemeData(
        sizing: VisirControlSizing(
          height: VisirControlSizeScale(sm: 36, md: 44, lg: 52),
          horizontalPadding: VisirControlSizeScale(sm: 8, md: 12, lg: 16),
          iconSpacing: 6,
          compactSpacing: 4,
        ),
        borders: VisirBorderStates(
          base: VisirBorderState(color: Colors.white, width: 1),
          hover: VisirBorderState(color: Colors.white, width: 1),
          focus: VisirBorderState(color: Colors.blue, width: 2),
          disabled: VisirBorderState(color: Colors.grey, width: 1),
        ),
        radius: 12,
        interaction: interaction,
      );

      final updated = control.copyWith(
        interaction: interaction.copyWith(pressedScale: 0.9),
      );

      expect(control.copyWith(), control);
      expect(updated, isNot(control));
      expect(updated.interaction.pressedScale, 0.9);
      expect(updated.interaction.pressedOpacity, 0.5);
      expect(updated.sizing, control.sizing);
    },
  );

  test('VisirComponentThemes copyWith syncs control interaction tokens', () {
    const interaction = VisirControlInteractionThemeData(
      pressedScale: 0.96,
      pressedOpacity: 0.5,
      disabledOpacity: 0.45,
    );
    const control = VisirControlThemeData(
      sizing: VisirControlSizing(
        height: VisirControlSizeScale(sm: 36, md: 44, lg: 52),
        horizontalPadding: VisirControlSizeScale(sm: 8, md: 12, lg: 16),
        iconSpacing: 6,
        compactSpacing: 4,
      ),
      borders: VisirBorderStates(
        base: VisirBorderState(color: Colors.white, width: 1),
        hover: VisirBorderState(color: Colors.white, width: 1),
        focus: VisirBorderState(color: Colors.blue, width: 2),
        disabled: VisirBorderState(color: Colors.grey, width: 1),
      ),
      radius: 12,
      interaction: interaction,
    );
    final themes = VisirComponentThemes(
      button: const VisirButtonThemeData(
        glowBlur: 24,
        interaction: interaction,
      ),
      control: control,
      surface: const VisirSurfaceThemeData(
        padding: VisirSurfaceDensityScale(
          compact: 8,
          comfortable: 12,
          spacious: 16,
        ),
        radius: 20,
        borders: VisirBorderStates(
          base: VisirBorderState(color: Colors.white, width: 1),
          hover: VisirBorderState(color: Colors.white, width: 1),
          focus: VisirBorderState(color: Colors.blue, width: 2),
          disabled: VisirBorderState(color: Colors.grey, width: 1),
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
      content: const VisirContentThemeData(
        paddingHorizontal: 10,
        paddingVertical: 6,
        radius: 999,
        inlineSpacing: 8,
        compactSpacing: 4,
      ),
      feedback: const VisirFeedbackThemeData(
        size: VisirFeedbackSizeScale(sm: 12, md: 16, lg: 20),
        strokeWidth: 2,
        emphasisMuted: 0.6,
        emphasisStrong: 1,
      ),
    );

    final updated = themes.copyWith(
      control: control.copyWith(
        interaction: interaction.copyWith(pressedScale: 0.9),
      ),
    );

    expect(themes.copyWith(), themes);
    expect(updated, isNot(themes));
    expect(updated.control.interaction.pressedScale, 0.9);
    expect(updated.button.pressedScale, 0.9);
  });

  test('VisirComponentThemes normalizes mismatched interaction tokens', () {
    const buttonInteraction = VisirControlInteractionThemeData(
      pressedScale: 0.8,
      pressedOpacity: 0.3,
      disabledOpacity: 0.2,
    );
    const controlInteraction = VisirControlInteractionThemeData(
      pressedScale: 0.96,
      pressedOpacity: 0.5,
      disabledOpacity: 0.45,
    );
    final themes = VisirComponentThemes(
      button: const VisirButtonThemeData(
        glowBlur: 24,
        interaction: buttonInteraction,
      ),
      control: const VisirControlThemeData(
        sizing: VisirControlSizing(
          height: VisirControlSizeScale(sm: 36, md: 44, lg: 52),
          horizontalPadding: VisirControlSizeScale(sm: 8, md: 12, lg: 16),
          iconSpacing: 6,
          compactSpacing: 4,
        ),
        borders: VisirBorderStates(
          base: VisirBorderState(color: Colors.white, width: 1),
          hover: VisirBorderState(color: Colors.white, width: 1),
          focus: VisirBorderState(color: Colors.blue, width: 2),
          disabled: VisirBorderState(color: Colors.grey, width: 1),
        ),
        radius: 12,
        interaction: controlInteraction,
      ),
      surface: const VisirSurfaceThemeData(
        padding: VisirSurfaceDensityScale(
          compact: 8,
          comfortable: 12,
          spacious: 16,
        ),
        radius: 20,
        borders: VisirBorderStates(
          base: VisirBorderState(color: Colors.white, width: 1),
          hover: VisirBorderState(color: Colors.white, width: 1),
          focus: VisirBorderState(color: Colors.blue, width: 2),
          disabled: VisirBorderState(color: Colors.grey, width: 1),
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
      content: const VisirContentThemeData(
        paddingHorizontal: 10,
        paddingVertical: 6,
        radius: 999,
        inlineSpacing: 8,
        compactSpacing: 4,
      ),
      feedback: const VisirFeedbackThemeData(
        size: VisirFeedbackSizeScale(sm: 12, md: 16, lg: 20),
        strokeWidth: 2,
        emphasisMuted: 0.6,
        emphasisStrong: 1,
      ),
    );

    expect(themes.control.interaction, controlInteraction);
    expect(themes.button.interaction, controlInteraction);
  });

  test('VisirThemeData fallback exposes role-based component themes', () {
    final fallback = VisirThemeData.fallback();

    expect(
      fallback.components.control.sizing.heightFor(VisirButtonSize.md),
      44,
    );
    expect(
      fallback.components.surface.padding.paddingFor(VisirCardDensity.compact),
      12,
    );
    expect(fallback.components.content.paddingHorizontal, 10);
    expect(fallback.components.feedback.sizeFor(VisirSpinnerSize.lg), 20);
  });
}
