import 'package:flutter/material.dart';

import '../foundation/visir_enums.dart';
import 'visir_button.dart';

class VisirIconButton extends StatelessWidget {
  const VisirIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = VisirButtonVariant.secondary,
    this.size = VisirButtonSize.md,
    this.tooltip,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final VisirButtonVariant variant;
  final VisirButtonSize size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return VisirButton(
      label: '',
      onPressed: onPressed,
      variant: variant,
      size: size,
      tooltip: tooltip,
      leading: icon,
      isIconOnly: true,
    );
  }
}
