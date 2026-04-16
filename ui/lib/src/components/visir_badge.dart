import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import '../theme/visir_theme.dart';

class VisirBadge extends StatelessWidget {
  const VisirBadge({
    super.key,
    required this.label,
    this.tone = VisirBadgeTone.neutral,
  });

  final String label;
  final VisirBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = VisirTheme.of(context);
    final colors = theme.tokens.colors;
    final content = theme.components.content;
    final background = switch (tone) {
      VisirBadgeTone.neutral => colors.surfaceMuted,
      VisirBadgeTone.primary => colors.accent.withValues(alpha: 0.22),
      VisirBadgeTone.success => colors.success.withValues(alpha: 0.22),
      VisirBadgeTone.warning => colors.warning.withValues(alpha: 0.22),
      VisirBadgeTone.danger => colors.danger.withValues(alpha: 0.22),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: content.paddingHorizontal,
        vertical: content.paddingVertical,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(content.radius),
      ),
      child: Text(label),
    );
  }
}
