import 'package:flutter/material.dart';

import '../theme/visir_theme.dart';

class VisirDivider extends StatelessWidget {
  const VisirDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ColoredBox(
        color: VisirTheme.of(context).tokens.colors.surfaceOutline,
        child: const SizedBox(height: 1),
      ),
    );
  }
}
