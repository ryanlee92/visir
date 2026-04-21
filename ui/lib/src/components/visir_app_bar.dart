import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import '../theme/visir_theme.dart';
import 'visir_button.dart';

class VisirAppBarButton {
  const VisirAppBarButton.icon({
    this.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.tooltip,
  }) : isDivider = false,
       child = null;

  const VisirAppBarButton.child({
    this.key,
    required this.child,
    required this.semanticLabel,
    this.onPressed,
    this.tooltip,
  }) : isDivider = false,
       icon = null;

  const VisirAppBarButton.divider()
    : key = null,
      isDivider = true,
      icon = null,
      child = null,
      semanticLabel = null,
      onPressed = null,
      tooltip = null;

  final Key? key;
  final bool isDivider;
  final Widget? icon;
  final Widget? child;
  final String? semanticLabel;
  final VoidCallback? onPressed;
  final String? tooltip;

  Widget build(BuildContext context) {
    if (isDivider) {
      final colors = Theme.of(context).colorScheme;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          key: const ValueKey('visir-app-bar-divider'),
          width: 2,
          height: 16,
          color: colors.outlineVariant.withValues(alpha: 0.7),
        ),
      );
    }

    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: VisirButton(
          key: key,
          label: '',
          onPressed: onPressed,
          variant: VisirButtonVariant.secondary,
          size: VisirButtonSize.md,
          leading: icon,
          showShadow: false,
          isIconOnly: true,
          semanticLabel: semanticLabel,
          tooltip: tooltip,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: VisirButton(
        key: key,
        label: semanticLabel ?? '',
        onPressed: onPressed,
        showShadow: false,
        variant: VisirButtonVariant.secondary,
        size: VisirButtonSize.md,
        leading: child,
        tooltip: tooltip,
      ),
    );
  }
}

class VisirAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VisirAppBar({
    super.key,
    required this.title,
    required this.leadings,
    required this.trailings,
    this.backgroundColor,
  });

  static const double height = 47;

  final String title;
  final List<VisirAppBarButton> leadings;
  final List<VisirAppBarButton> trailings;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visirTheme = VisirTheme.of(context);
    final titleStyle = visirTheme.text.title.copyWith(
      color: theme.colorScheme.outlineVariant,
    );

    return Container(
      key: const ValueKey('visir-app-bar'),
      height: height,
      color: backgroundColor ?? theme.colorScheme.surface,
      child: Row(
        children: [
          const SizedBox(width: 4),
          ...leadings.map((button) => button.build(context)),
          if (leadings.isEmpty)
            const SizedBox(width: 6)
          else
            const SizedBox(width: 4),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(1),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ),
          if (trailings.isEmpty) const SizedBox(width: 6),
          ...trailings.map((button) => button.build(context)),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
