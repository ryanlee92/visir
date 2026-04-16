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
    final control = theme.components.control;
    final disabled = _isDisabled;
    final pressed = !disabled && _pressed;
    final verticalPadding = control.sizing.verticalPaddingFor(widget.size);
    final horizontalPadding = control.sizing.horizontalPaddingFor(widget.size);
    final iconSpacing = control.sizing.iconSpacing;
    final hasLabel = !widget.isIconOnly;
    final foregroundColor = _foregroundColor(theme);
    final semanticsLabel =
        widget.semanticLabel ?? (hasLabel ? widget.label : null);

    final visualChild = DecoratedBox(
      decoration: _decoration(theme, disabled),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(control.radius),
        child: ColoredBox(
          key: const ValueKey('visir-button-hover-overlay'),
          color: _hoverOverlayColor(theme, disabled),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor),
              child: Row(
                mainAxisSize: widget.isExpanded
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leading != null) widget.leading!,
                  if (widget.leading != null && hasLabel)
                    SizedBox(width: iconSpacing),
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
                    if (hasLabel) SizedBox(width: iconSpacing),
                    widget.variant == VisirButtonVariant.primary
                        ? VisirTheme(
                            data: theme.copyWith(
                              tokens: theme.tokens.copyWith(
                                colors: theme.tokens.colors.copyWith(
                                  text: Colors.white,
                                ),
                              ),
                            ),
                            child: VisirSpinner(
                              size: _spinnerSize(),
                              tone: _spinnerTone(),
                            ),
                          )
                        : VisirSpinner(
                            size: _spinnerSize(),
                            tone: _spinnerTone(),
                          ),
                  ],
                  if (widget.trailing != null) ...[
                    if (hasLabel || widget.isLoading)
                      SizedBox(width: iconSpacing),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final animatedVisual = AnimatedOpacity(
      duration: theme.tokens.motion.normal,
      curve: theme.tokens.motion.curve,
      opacity: disabled
          ? control.interaction.disabledOpacity
          : pressed
          ? control.interaction.pressedOpacity
          : 1,
      child: TweenAnimationBuilder<double>(
        duration: theme.tokens.motion.emphasized,
        curve: theme.tokens.motion.curve,
        tween: Tween<double>(
          end: pressed ? control.interaction.pressedScale : 1,
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
      key: const ValueKey('visir-button-shell'),
      width: widget.isExpanded ? double.infinity : null,
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
    final control = theme.components.control;
    final colors = theme.tokens.colors;
    final isPrimary = widget.variant == VisirButtonVariant.primary;
    final isGhost = widget.variant == VisirButtonVariant.ghost;
    final isDanger = widget.variant == VisirButtonVariant.danger;
    final isHovered = !disabled && _hovering;
    const dangerFill = Color(0x52E13A5F);
    const dangerFillHovered = Color(0x61E13A5F);
    final borderState = disabled
        ? control.borders.disabled
        : _focused
        ? control.borders.focus
        : isHovered
        ? control.borders.hover
        : control.borders.base;

    final background = switch (widget.variant) {
      VisirButtonVariant.primary => LinearGradient(
        colors: [
          Color.lerp(colors.accent, Colors.white, isHovered ? 0.04 : 0)!,
          Color.lerp(colors.accentStrong, Colors.white, isHovered ? 0.02 : 0)!,
        ],
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
          ? (isHovered
                ? colors.surfaceOutline.withValues(alpha: 0.08)
                : Colors.transparent)
          : isDanger
          ? (isHovered ? dangerFillHovered : dangerFill)
          : Color.lerp(colors.surface, colors.text, isHovered ? 0.05 : 0)!,
      borderRadius: BorderRadius.circular(control.radius),
      border: Border.all(color: borderState.color, width: borderState.width),
      boxShadow: [
        if (isPrimary)
          BoxShadow(
            color: colors.accent.withValues(
              alpha: disabled ? 0.08 : (isHovered ? 0.42 : 0.34),
            ),
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

  Color _hoverOverlayColor(VisirThemeData theme, bool disabled) {
    if (disabled || !_hovering) {
      return Colors.transparent;
    }

    final colors = theme.tokens.colors;

    return switch (widget.variant) {
      VisirButtonVariant.primary => colors.text.withValues(alpha: 0.06),
      VisirButtonVariant.secondary => colors.text.withValues(alpha: 0.08),
      VisirButtonVariant.ghost => colors.text.withValues(alpha: 0.03),
      VisirButtonVariant.danger => colors.text.withValues(alpha: 0.04),
    };
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
      VisirButtonVariant.primary => Colors.white,
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
    return VisirSpinnerTone.inverse;
  }
}
