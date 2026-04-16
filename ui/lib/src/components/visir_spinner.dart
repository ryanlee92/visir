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
    final theme = VisirTheme.of(context);
    final colors = theme.tokens.colors;
    final feedback = theme.components.feedback;
    final color = switch (tone) {
      VisirSpinnerTone.neutral => colors.textMuted,
      VisirSpinnerTone.primary => colors.textInverse,
      VisirSpinnerTone.inverse => colors.text,
    };
    final spinnerSize = feedback.sizeFor(size);

    return SizedBox(
      width: spinnerSize,
      height: spinnerSize,
      child: CircularProgressIndicator(
        strokeWidth: feedback.strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
