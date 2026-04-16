import 'package:flutter/material.dart';

import '../theme/visir_theme.dart';

class VisirDivider extends StatelessWidget {
  const VisirDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final border = VisirTheme.of(context).components.surface.borders.base;

    return SizedBox(
      width: double.infinity,
      child: ColoredBox(
        color: border.color,
        child: SizedBox(height: border.width),
      ),
    );
  }
}
