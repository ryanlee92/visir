import 'package:flutter/material.dart';

import 'playground_panel.dart';

class CodeSnippetPanel extends StatefulWidget {
  const CodeSnippetPanel({super.key, required this.title, required this.code});

  final String title;
  final String code;

  @override
  State<CodeSnippetPanel> createState() => _CodeSnippetPanelState();
}

class _CodeSnippetPanelState extends State<CodeSnippetPanel> {
  late final ScrollController _verticalController = ScrollController();
  late final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final codeTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
      fontSize: 13,
      height: 1.45,
      color: theme.colorScheme.onSurface,
    );

    return PlaygroundPanel(
      title: widget.title,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 136, maxHeight: 320),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dart',
              style: theme.textTheme.labelMedium?.copyWith(
                letterSpacing: 0.4,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Scrollbar(
                    controller: _verticalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalController,
                      primary: false,
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        notificationPredicate: (notification) {
                          return notification.metrics.axis == Axis.horizontal;
                        },
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          primary: false,
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: SelectableText(
                              widget.code,
                              style: codeTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
