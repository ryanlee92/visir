import 'package:flutter/material.dart';

import '../theme/visir_theme.dart';

class VisirEmptyState extends StatelessWidget {
  const VisirEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.action,
  });

  final String title;
  final String description;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = VisirTheme.of(context);
    final text = theme.text;
    final content = theme.components.content;
    final surface = theme.components.surface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: text.title),
        SizedBox(height: content.inlineSpacing),
        Text(description, textAlign: TextAlign.center, style: text.body),
        SizedBox(height: surface.padding.comfortable),
        action,
      ],
    );
  }
}
