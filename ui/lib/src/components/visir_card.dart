import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/visir_enums.dart';
import '../foundation/visir_tokens.dart';
import '../theme/visir_component_role_themes.dart';
import '../theme/visir_theme.dart';

enum VisirCardBorder { none, base }

class VisirCard extends StatefulWidget {
  const VisirCard({
    super.key,
    required this.child,
    this.variant = VisirCardVariant.elevated,
    this.border = VisirCardBorder.none,
    this.showShadow = true,
    this.density = VisirCardDensity.comfortable,
    this.onTap,
  });

  final Widget child;
  final VisirCardVariant variant;
  final VisirCardBorder border;
  final bool showShadow;
  final VisirCardDensity density;
  final VoidCallback? onTap;

  @override
  State<VisirCard> createState() => _VisirCardState();
}

class _VisirCardState extends State<VisirCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = VisirTheme.of(context);
    final tokens = theme.tokens;
    final surface = theme.components.surface;
    final padding = switch (widget.density) {
      VisirCardDensity.compact => EdgeInsets.all(surface.padding.compact),
      VisirCardDensity.comfortable => EdgeInsets.all(
        surface.padding.comfortable,
      ),
      VisirCardDensity.spacious => EdgeInsets.all(surface.padding.spacious),
    };

    final isInteractive = widget.onTap != null;
    final decoration = _buildDecoration(
      tokens,
      surface,
      isInteractive && _focused,
    );
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

  BoxDecoration _buildDecoration(
    VisirTokens tokens,
    VisirSurfaceThemeData surface,
    bool focused,
  ) {
    final baseShadows =
        widget.variant == VisirCardVariant.elevated && widget.showShadow
        ? [
            BoxShadow(
              color: tokens.colors.surfaceOutline.withValues(
                alpha: surface.elevation.baseOpacity,
              ),
              blurRadius: surface.elevation.baseBlur,
              offset: Offset(0, surface.elevation.baseOffsetY),
            ),
          ]
        : const <BoxShadow>[];
    final shadows = focused
        ? [
            ...baseShadows,
            BoxShadow(
              color: tokens.colors.accent.withValues(
                alpha: surface.elevation.focusOpacity,
              ),
              blurRadius: surface.elevation.focusBlur,
              spreadRadius: surface.elevation.focusSpread,
            ),
          ]
        : baseShadows;
    final borderState = focused ? surface.borders.focus : surface.borders.base;
    final Border? border = switch (widget.variant) {
      VisirCardVariant.elevated => null,
      VisirCardVariant.muted || VisirCardVariant.outlined =>
        widget.border == VisirCardBorder.base
            ? Border.all(color: borderState.color, width: borderState.width)
            : null,
    };

    return BoxDecoration(
      color: switch (widget.variant) {
        VisirCardVariant.elevated => tokens.colors.surface,
        VisirCardVariant.muted => tokens.colors.surfaceMuted,
        VisirCardVariant.outlined => Colors.transparent,
      },
      borderRadius: BorderRadius.circular(surface.radius),
      border: border,
      boxShadow: shadows,
    );
  }
}
