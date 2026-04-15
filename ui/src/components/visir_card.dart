import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import '../theme/visir_theme.dart';

class VisirCard extends StatelessWidget {
  const VisirCard({
    super.key,
    required this.child,
    this.variant = VisirCardVariant.elevated,
    this.density = VisirCardDensity.comfortable,
    this.onTap,
  });

  final Widget child;
  final VisirCardVariant variant;
  final VisirCardDensity density;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = VisirTheme.of(context).tokens;
    final padding = switch (density) {
      VisirCardDensity.compact => EdgeInsets.all(tokens.spacing.md),
      VisirCardDensity.comfortable => EdgeInsets.all(tokens.spacing.lg),
      VisirCardDensity.spacious => EdgeInsets.all(tokens.spacing.xl),
    };

    final decoration = BoxDecoration(
      color: switch (variant) {
        VisirCardVariant.elevated => tokens.colors.surface,
        VisirCardVariant.muted => tokens.colors.surfaceMuted,
        VisirCardVariant.outlined => Colors.transparent,
      },
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      border: Border.all(color: tokens.colors.surfaceOutline),
      boxShadow: variant == VisirCardVariant.elevated
          ? [
              BoxShadow(
                color: tokens.colors.accent.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ]
          : const [],
    );

    final body = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) {
      return body;
    }

    return GestureDetector(onTap: onTap, child: body);
  }
}
