import 'package:flutter/material.dart';

import 'playground_panel.dart';

class CodeSnippetPanel extends StatelessWidget {
  const CodeSnippetPanel({super.key, required this.title, required this.code});

  final String title;
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PlaygroundPanel(
      title: title,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 280),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              primary: false,
              child: SingleChildScrollView(
                primary: false,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: SelectableText(
                    code,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
