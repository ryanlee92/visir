import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/visir_enums.dart';
import '../theme/visir_theme.dart';
import '../theme/visir_theme_data.dart';
import 'visir_spinner.dart';

class VisirButton extends StatefulWidget {
  const VisirButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = VisirButtonVariant.primary,
    this.size = VisirButtonSize.md,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.isExpanded = false,
    this.tooltip,
    this.autofocus = false,
    this.focusNode,
    this.isIconOnly = false,
    this.semanticLabel,
  }) : assert(
         !isIconOnly || (semanticLabel != null && semanticLabel != ''),
         'Icon-only buttons require a semanticLabel.',
       );

  final String label;
  final VoidCallback? onPressed;
  final VisirButtonVariant variant;
  final VisirButtonSize size;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final bool isExpanded;
  final String? tooltip;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool isIconOnly;
  final String? semanticLabel;

  @override
  State<VisirButton> createState() => _VisirButtonState();
}

class _VisirButtonState extends State<VisirButton> {
  final FocusNode _internalFocusNode = FocusNode();
  bool _hovering = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  bool get _showsInteractionFeedback => !_isDisabled && (_pressed || _hovering);

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void didUpdateWidget(covariant VisirButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isDisabled && (_hovering || _pressed)) {
      _hovering = false;
      _pressed = false;
    }

    if (_isDisabled && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = VisirTheme.of(context);
    final disabled = _isDisabled;
    final height = switch (widget.size) {
      VisirButtonSize.sm => 36.0,
      VisirButtonSize.md => 44.0,
      VisirButtonSize.lg => 52.0,
    };
    final horizontalPadding = switch (widget.size) {
      VisirButtonSize.sm => theme.tokens.spacing.md.toDouble(),
      VisirButtonSize.md => theme.tokens.spacing.lg.toDouble(),
      VisirButtonSize.lg => theme.tokens.spacing.xl.toDouble(),
    };
    final hasLabel = !widget.isIconOnly;
    final foregroundColor = _foregroundColor(theme);
    final semanticsLabel =
        widget.semanticLabel ?? (hasLabel ? widget.label : null);

    final visualChild = DecoratedBox(
      decoration: _decoration(theme, disabled),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: IconTheme.merge(
          data: IconThemeData(color: foregroundColor),
          child: Row(
            mainAxisSize: widget.isExpanded
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leading != null) widget.leading!,
              if (widget.leading != null && hasLabel) const SizedBox(width: 8),
              if (hasLabel)
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _labelStyle(theme),
                  ),
                ),
              if (widget.isLoading) ...[
                if (hasLabel) const SizedBox(width: 8),
                VisirSpinner(size: _spinnerSize(), tone: _spinnerTone()),
              ],
              if (widget.trailing != null) ...[
                if (hasLabel || widget.isLoading) const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );

    final animatedVisual = AnimatedOpacity(
      duration: theme.tokens.motion.normal,
      curve: theme.tokens.motion.curve,
      opacity: disabled ? theme.components.button.disabledOpacity : 1,
      child: TweenAnimationBuilder<double>(
        duration: theme.tokens.motion.emphasized,
        curve: theme.tokens.motion.curve,
        tween: Tween<double>(
          end: _showsInteractionFeedback
              ? theme.components.button.pressedScale
              : 1,
        ),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            transformHitTests: false,
            child: child,
          );
        },
        child: visualChild,
      ),
    );

    Widget child = SizedBox(
      width: widget.isExpanded ? double.infinity : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: MergeSemantics(
          child: Semantics(
            button: true,
            enabled: !disabled,
            label: semanticsLabel,
            onTap: disabled ? null : widget.onPressed,
            child: Focus(
              focusNode: _focusNode,
              autofocus: !disabled && widget.autofocus,
              canRequestFocus: !disabled,
              skipTraversal: disabled,
              onFocusChange: _handleFocusChange,
              onKeyEvent: disabled ? null : _handleKeyEvent,
              child: MouseRegion(
                cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
                onEnter: disabled ? null : _handleHoverEnter,
                onExit: disabled ? null : _handleHoverExit,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: disabled ? null : _handleTapDown,
                  onTapCancel: disabled ? null : _handleTapCancel,
                  onTapUp: disabled ? null : _handleTapUp,
                  onTap: disabled ? null : widget.onPressed,
                  child: Center(child: animatedVisual),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip case final tooltip?) {
      child = Tooltip(message: tooltip, child: child);
    }

    return child;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_isDisabled) {
      return KeyEventResult.ignored;
    }

    final isActivationKey =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space;

    if (event is KeyUpEvent && isActivationKey) {
      widget.onPressed?.call();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (_hovering) {
      return;
    }

    setState(() => _hovering = true);
  }

  void _handleFocusChange(bool focused) {
    if (_focused == focused) {
      return;
    }

    setState(() => _focused = focused);
  }

  void _handleHoverExit(PointerExitEvent event) {
    _clearInteractionState();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_pressed) {
      return;
    }

    setState(() => _pressed = true);
  }

  void _handleTapCancel() {
    if (!_pressed) {
      return;
    }

    setState(() => _pressed = false);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_pressed) {
      return;
    }

    setState(() => _pressed = false);
  }

  void _clearInteractionState() {
    if (!_hovering && !_pressed) {
      return;
    }

    setState(() {
      _hovering = false;
      _pressed = false;
    });
  }

  BoxDecoration _decoration(VisirThemeData theme, bool disabled) {
    final colors = theme.tokens.colors;
    final isPrimary = widget.variant == VisirButtonVariant.primary;
    final isGhost = widget.variant == VisirButtonVariant.ghost;
    final isDanger = widget.variant == VisirButtonVariant.danger;

    final background = switch (widget.variant) {
      VisirButtonVariant.primary => LinearGradient(
        colors: [colors.accent, colors.accentStrong],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      VisirButtonVariant.secondary => null,
      VisirButtonVariant.ghost => null,
      VisirButtonVariant.danger => null,
    };

    return BoxDecoration(
      gradient: background,
      color: isPrimary
          ? null
          : isGhost
          ? Colors.transparent
          : isDanger
          ? colors.danger.withValues(alpha: 0.22)
          : colors.surface,
      borderRadius: BorderRadius.circular(theme.tokens.radius.md),
      border: Border.all(
        color: _focused ? colors.accent : colors.surfaceOutline,
        width: _focused ? 2 : 1,
      ),
      boxShadow: [
        if (isPrimary)
          BoxShadow(
            color: colors.accent.withValues(alpha: disabled ? 0.08 : 0.34),
            blurRadius: theme.components.button.glowBlur,
            offset: const Offset(0, 10),
          ),
        if (_focused)
          BoxShadow(
            color: colors.accent.withValues(alpha: disabled ? 0.12 : 0.24),
            blurRadius: theme.components.button.glowBlur,
            spreadRadius: 1,
          ),
      ],
    );
  }

  TextStyle _labelStyle(VisirThemeData theme) {
    return TextStyle(
      color: _foregroundColor(theme),
      fontSize: switch (widget.size) {
        VisirButtonSize.sm => 13,
        VisirButtonSize.md => 15,
        VisirButtonSize.lg => 17,
      }.toDouble(),
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
  }

  Color _foregroundColor(VisirThemeData theme) {
    return switch (widget.variant) {
      VisirButtonVariant.primary => theme.tokens.colors.textInverse,
      VisirButtonVariant.secondary => theme.tokens.colors.text,
      VisirButtonVariant.ghost => theme.tokens.colors.textMuted,
      VisirButtonVariant.danger => theme.tokens.colors.text,
    };
  }

  VisirSpinnerSize _spinnerSize() {
    return switch (widget.size) {
      VisirButtonSize.sm => VisirSpinnerSize.sm,
      VisirButtonSize.md => VisirSpinnerSize.md,
      VisirButtonSize.lg => VisirSpinnerSize.lg,
    };
  }

  VisirSpinnerTone _spinnerTone() {
    return widget.variant == VisirButtonVariant.primary
        ? VisirSpinnerTone.primary
        : VisirSpinnerTone.inverse;
  }
}
