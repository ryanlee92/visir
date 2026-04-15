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
    final colors = VisirTheme.of(context).tokens.colors;
    final background = switch (tone) {
      VisirBadgeTone.neutral => colors.surfaceMuted,
      VisirBadgeTone.primary => colors.accent.withValues(alpha: 0.22),
      VisirBadgeTone.success => colors.success.withValues(alpha: 0.22),
      VisirBadgeTone.warning => colors.warning.withValues(alpha: 0.22),
      VisirBadgeTone.danger => colors.danger.withValues(alpha: 0.22),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
