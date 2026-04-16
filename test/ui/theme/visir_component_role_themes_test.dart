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

    final updated = states.copyWith(
      hover: hover.copyWith(width: 3),
    );

    expect(updated, isNot(states));
    expect(updated.base, base);
    expect(updated.focus, focus);
    expect(updated.disabled, disabled);
    expect(updated.hover.width, 3);
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
    expect(
      fallback.components.feedback.sizeFor(VisirSpinnerSize.lg),
      20,
    );
  });
}
