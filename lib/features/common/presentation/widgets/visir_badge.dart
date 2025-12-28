import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';

class VisirBadge extends StatelessWidget {
  final TextStyle style;
  final String text;
  final double horizontalPadding;
  final bool? isShortcutBadge;

  const VisirBadge({super.key, required this.style, required this.text, required this.horizontalPadding, this.isShortcutBadge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isShortcutBadge == true ? context.tertiary.withValues(alpha: 0.25) : context.tertiary,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: EdgeInsets.only(left: horizontalPadding),
      child: Text(
        text,
        style: style.copyWith(color: context.onTertiary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
