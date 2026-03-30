// visir/packages/visir_design_system/lib/src/widgets/visir_button.dart
//
// VisirButton - a reusable design-system button used across the Visir app.
// This file provides a single widget implementation (and its enum) so the
// package can export the widget individually from `lib/src/...` and keep a
// small surface area for consumers.
//
// Keep the API intentionally small and stable. Expand with additional
// accessibility, theming, or visual variants as needed.

import 'package:flutter/material.dart';

/// Small set of design tokens used by the Visir button component.
///
/// These are intentionally local to this widget file so the widget is safe to
/// export independently. When the design system grows, consider moving tokens
/// to a shared file under `lib/src/tokens/`.
class _VisirButtonTokens {
  _VisirButtonTokens._();

  static const double buttonHeight = 44.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8));
  static const double minTouchTarget = 48.0;
  static const Color primaryColor = Color(0xFF5B2DD3);
  static const Color onPrimary = Colors.white;
}

/// Variant options for the `VisirButton`.
enum VisirButtonVariant { primary, secondary, ghost }

/// VisirButton
///
/// An opinionated, accessible, and theme-aware button intended as a
/// design-system primitive for the Visir app.
///
/// Features:
///  - Primary, secondary and ghost variants.
///  - Optional `leading` and `trailing` widgets (icons, loaders).
///  - Proper semantics and default minimum touch target sizing.
///  - Simple API suitable for widespread reuse.
class VisirButton extends StatelessWidget {
  const VisirButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.variant = VisirButtonVariant.primary,
    this.height,
    this.padding,
    this.borderRadius,
    this.elevation = 0,
    this.tooltip,
    this.maxWidth,
    this.expandHitArea = EdgeInsets.zero,
  });

  /// Additional area around the visual button that should show the tooltip
  /// and count as a touch/hover target. This expands the region that the
  /// Tooltip watches and can be used to provide a more forgiving touch area.
  /// Defaults to `EdgeInsets.zero` (no expansion).
  final EdgeInsets expandHitArea;

  /// The text label shown inside the button.
  final String label;

  /// Callback invoked when the button is pressed. If `null` the button is
  /// disabled and rendered in a disabled appearance.
  final VoidCallback? onPressed;

  /// Optional widget displayed before the label (commonly an icon).
  final Widget? leading;

  /// Optional widget displayed after the label (commonly an icon or loader).
  final Widget? trailing;

  /// Visual variant of the button.
  final VisirButtonVariant variant;

  /// Optional override for button height. If `null` uses token default.
  final double? height;

  /// Optional override for content padding.
  final EdgeInsets? padding;

  /// Optional override for corner radius.
  final BorderRadius? borderRadius;

  /// Optional elevation for the button's material.
  final double elevation;

  /// Optional tooltip for additional context (useful for icon-only buttons).
  final String? tooltip;

  /// Optional maximum width constraint. Useful for buttons that should
  /// expand to fill available width when not constrained by parent.
  final double? maxWidth;

  bool get _isEnabled => onPressed != null;

  Color _backgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (variant) {
      case VisirButtonVariant.ghost:
        return Colors.transparent;
      case VisirButtonVariant.secondary:
        // Use surface color for subtle secondary appearance
        return theme.colorScheme.surface;
      case VisirButtonVariant.primary:
      default:
        return _VisirButtonTokens.primaryColor;
    }
  }

  Color _foregroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (variant) {
      case VisirButtonVariant.primary:
        return _VisirButtonTokens.onPrimary;
      case VisirButtonVariant.secondary:
      case VisirButtonVariant.ghost:
      default:
        return theme.textTheme.bodyMedium?.color ?? Colors.black87;
    }
  }

  ButtonStyle _buildStyle(BuildContext context) {
    final bg = _backgroundColor(context);
    final fg = _foregroundColor(context);
    final radius = borderRadius ?? _VisirButtonTokens.borderRadius;

    return ElevatedButton.styleFrom(
      elevation: elevation,
      backgroundColor: _isEnabled ? bg : bg.withOpacity(0.5),
      foregroundColor: fg,
      padding: padding ?? _VisirButtonTokens.buttonPadding,
      shape: RoundedRectangleBorder(borderRadius: radius),
      minimumSize: Size(64, height ?? _VisirButtonTokens.buttonHeight),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildContent(BuildContext context) {
    final fg = _foregroundColor(context);
    final children = <Widget>[];

    if (leading != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconTheme.merge(
            data: IconThemeData(size: 18, color: fg),
            child: leading!,
          ),
        ),
      );
    }

    children.add(
      Flexible(
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(color: fg),
        ),
      ),
    );

    if (trailing != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconTheme.merge(
            data: IconThemeData(size: 18, color: fg),
            child: trailing!,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: _buildStyle(context),
      child: _buildContent(context),
    );

    Widget constrained = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height ?? _VisirButtonTokens.buttonHeight,
        maxWidth: maxWidth ?? double.infinity,
      ),
      child: button,
    );

    // Ensure accessible touch target for icon-only scenarios:
    constrained = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: _VisirButtonTokens.minTouchTarget,
        minHeight: _VisirButtonTokens.minTouchTarget,
      ),
      child: Center(child: constrained),
    );

    final semantics = Semantics(
      button: true,
      enabled: _isEnabled,
      label: label,
      child: constrained,
    );

    // Wrap the semantics with padding defined by `expandHitArea` so the tooltip
    // and hover area are expanded. Placing the Tooltip outside this padded
    // region ensures hovering or long-pressing anywhere inside the expanded
    // area will show the Tooltip.
    final Widget padded = Padding(padding: expandHitArea, child: semantics);

    // If expandHitArea is non-zero, ensure taps in the padded area are forwarded
    // to the inner button by adding a translucent GestureDetector around it.
    // This makes the expanded region interactive while preserving visuals.
    final Widget interactive = expandHitArea != EdgeInsets.zero
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onPressed,
            child: padded,
          )
        : padded;

    if (tooltip != null && tooltip!.isNotEmpty) {
      // Tooltip must be outside (wrap) the interactive semantics so hover/long-press
      // works across the expanded area.
      return Tooltip(message: tooltip!, child: interactive);
    }

    return interactive;
  }
}
