import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/visir_enums.dart';
import '../foundation/visir_tokens.dart';
import '../theme/visir_theme.dart';

class VisirCard extends StatefulWidget {
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
  State<VisirCard> createState() => _VisirCardState();
}

class _VisirCardState extends State<VisirCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = VisirTheme.of(context).tokens;
    final padding = switch (widget.density) {
      VisirCardDensity.compact => EdgeInsets.all(tokens.spacing.md),
      VisirCardDensity.comfortable => EdgeInsets.all(tokens.spacing.lg),
      VisirCardDensity.spacious => EdgeInsets.all(tokens.spacing.xl),
    };

    final isInteractive = widget.onTap != null;
    final decoration = _buildDecoration(tokens, isInteractive && _focused);
    final body = Container(
      padding: padding,
      decoration: decoration,
      child: widget.child,
    );

    if (!isInteractive) {
      return body;
    }

    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: true,
        child: Focus(
          onFocusChange: (focused) {
            if (_focused == focused) {
              return;
            }

            setState(() => _focused = focused);
          },
          onKeyEvent: _handleKeyEvent,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final isActivationKey =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space;

    if (event is KeyUpEvent && isActivationKey) {
      widget.onTap?.call();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  BoxDecoration _buildDecoration(VisirTokens tokens, bool focused) {
    final baseShadows = widget.variant == VisirCardVariant.elevated
        ? [
            BoxShadow(
              color: tokens.colors.accent.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ]
        : const <BoxShadow>[];
    final shadows = focused
        ? [
            ...baseShadows,
            BoxShadow(
              color: tokens.colors.accent.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ]
        : baseShadows;

    return BoxDecoration(
      color: switch (widget.variant) {
        VisirCardVariant.elevated => tokens.colors.surface,
        VisirCardVariant.muted => tokens.colors.surfaceMuted,
        VisirCardVariant.outlined => Colors.transparent,
      },
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      border: Border.all(
        color: focused ? tokens.colors.accent : tokens.colors.surfaceOutline,
        width: focused ? 2 : 1,
      ),
      boxShadow: shadows,
    );
  }
}
