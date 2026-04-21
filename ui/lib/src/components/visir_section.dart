import 'package:flutter/material.dart';

import '../theme/visir_theme.dart';

class VisirSection extends StatelessWidget {
  const VisirSection({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final visirTheme = VisirTheme.of(context);
    final spacing = visirTheme.components.surface.padding.compact;
    final titleStyle = visirTheme.text.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(title!, style: titleStyle),
          SizedBox(height: spacing),
        ],
        child,
      ],
    );
  }
}
