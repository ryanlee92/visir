import 'package:flutter/material.dart';

import '../theme/visir_theme.dart';

class VisirSection extends StatelessWidget {
  const VisirSection({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = VisirTheme.of(context).components.surface.padding.compact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[Text(title!), SizedBox(height: spacing)],
        child,
      ],
    );
  }
}
