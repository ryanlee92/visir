// visir/packages/visir_design_system/lib/src/widgets/visir_icon.dart
//
// VisirIcon - a small, flexible icon/avatar component for the Visir design system.
//
// Features:
//  - Circular or rounded-rect backgrounds
//  - Single color fill or two-color gradient background
//  - Optional image avatar (via ImageProvider) or IconData
//  - Tappable with ripple effect (uses InkWell inside Material)
//  - Tooltip and semantics for accessibility
//  - Ensures a minimum touch target (48x48) for comfortable interaction
//
// Usage examples:
//  VisirIcon(icon: Icons.calendar_today, tooltip: 'Calendar', onTap: () {...});
//
//  VisirIcon(
//    image: NetworkImage('https://...'),
//    size: 40,
//    borderRadius: BorderRadius.circular(8),
//  );

import 'package:flutter/material.dart';

/// The shape type for the VisirIcon background.
enum VisirIconShape { circular, roundedRect }

/// A compact, accessible icon/avatar widget used throughout the Visir UI.
///
/// Either [icon] or [image] may be provided. If both are provided, [image]
/// takes precedence and [icon] will not be displayed.
class VisirIcon extends StatelessWidget {
  const VisirIcon({
    super.key,
    this.icon,
    this.image,
    this.size,
    this.backgroundColor,
    this.gradient,
    this.iconColor,
    this.onTap,
    this.tooltip,
    this.shape = VisirIconShape.circular,
    this.borderRadius,
    this.padding = const EdgeInsets.all(6),
    this.elevation = 0,
    this.semanticLabel,
  }) : assert(
         icon != null || image != null,
         'Either icon or image must be provided',
       );

  /// Icon to display when [image] is not provided.
  final IconData? icon;

  /// Optional image to display (NetworkImage, AssetImage, FileImage, etc.).
  /// When provided, this is rendered in place of [icon].
  final ImageProvider<Object>? image;

  /// Visual size of the icon graphic (not the touch target). Defaults to 28.
  final double? size;

  /// Background color when not using a gradient.
  final Color? backgroundColor;

  /// Optional background gradient. When provided, it overrides [backgroundColor].
  final Gradient? gradient;

  /// Color for the icon glyph or image fallback (tint is applied only to Icon).
  final Color? iconColor;

  /// Callback when the widget is tapped. When `null`, the widget is non-interactive.
  final VoidCallback? onTap;

  /// Tooltip message shown on long-press or hover.
  final String? tooltip;

  /// Shape of the background (circular or rounded rectangle).
  final VisirIconShape shape;

  /// Corner radius used when [shape] is [VisirIconShape.roundedRect].
  /// If `null`, a default radius proportional to [size] will be used.
  final BorderRadius? borderRadius;

  /// Inner padding around the icon glyph/image.
  final EdgeInsets padding;

  /// Material elevation to optionally lift the widget visually.
  final double elevation;

  /// Explicit semantic label. Falls back to [tooltip] then an empty string.
  final String? semanticLabel;

  static const double _defaultIconSize = 28.0;
  static const double _minTouchSize = 48.0;
  static const Color _defaultBackground = Color(0xFFF3F3F5);
  static const Color _defaultPrimary = Color(0xFF5B2DD3);

  BorderRadius _resolveRadius(double resolvedSize) {
    if (shape == VisirIconShape.circular) {
      return BorderRadius.circular(resolvedSize);
    }
    return borderRadius ?? BorderRadius.circular(resolvedSize * 0.25);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? _defaultIconSize;
    final bgColor = backgroundColor ?? _defaultBackground;
    final fgColor = iconColor ?? _defaultPrimary;
    final radius = _resolveRadius(resolvedSize);

    // Build the visual child (image or icon)
    Widget visual;
    if (image != null) {
      visual = ClipRRect(
        borderRadius: radius,
        child: Image(
          image: image!,
          width: resolvedSize,
          height: resolvedSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon if image fails to load.
            return Icon(
              icon ?? Icons.person,
              size: resolvedSize,
              color: fgColor,
            );
          },
        ),
      );
      // If an image is used, we still want to place it on a background if a gradient/color is provided.
      visual = Container(
        width: resolvedSize + padding.horizontal,
        height: resolvedSize + padding.vertical,
        padding: padding,
        decoration: gradient == null
            ? BoxDecoration(color: bgColor, borderRadius: radius)
            : BoxDecoration(gradient: gradient, borderRadius: radius),
        child: Center(child: visual),
      );
    } else {
      visual = Container(
        padding: padding,
        decoration: gradient == null
            ? BoxDecoration(color: bgColor, borderRadius: radius)
            : BoxDecoration(gradient: gradient, borderRadius: radius),
        child: Icon(icon, size: resolvedSize, color: fgColor),
      );
    }

    // Ensure the tap target is at least 48x48
    final constrained = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: _minTouchSize,
        minHeight: _minTouchSize,
      ),
      child: Center(child: visual),
    );

    // Ink splash requires a Material ancestor. Use transparent Material when
    // elevation is zero to still get proper ink behavior on tap.
    final material = Material(
      color: Colors.transparent,
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(borderRadius: radius, onTap: onTap, child: constrained),
    );

    final labeled = Semantics(
      button: onTap != null,
      label: semanticLabel ?? tooltip ?? '',
      child: material,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: labeled);
    }
    return labeled;
  }
}
