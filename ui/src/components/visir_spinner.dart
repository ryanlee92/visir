import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import '../theme/visir_theme.dart';

class VisirSpinner extends StatelessWidget {
  const VisirSpinner({
    super.key,
    this.size = VisirSpinnerSize.md,
    this.tone = VisirSpinnerTone.primary,
  });

  final VisirSpinnerSize size;
  final VisirSpinnerTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = VisirTheme.of(context).tokens.colors;
    final color = switch (tone) {
      VisirSpinnerTone.neutral => colors.textMuted,
      VisirSpinnerTone.primary => colors.textInverse,
      VisirSpinnerTone.inverse => colors.text,
    };

    final spinnerSize = switch (size) {
      VisirSpinnerSize.sm => 12.0,
      VisirSpinnerSize.md => 16.0,
      VisirSpinnerSize.lg => 20.0,
    };

    return SizedBox(
      width: spinnerSize,
      height: spinnerSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
