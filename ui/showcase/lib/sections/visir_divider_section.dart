import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../playground/code_snippet_panel.dart';
import '../playground/playground_panel.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirDividerSection extends StatelessWidget {
  const VisirDividerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirDivider',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Thin separator for visual rhythm between grouped content.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              minHeight: 130,
              child: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top group',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    const VisirDivider(),
                    const SizedBox(height: 8),
                    Text(
                      'Bottom group',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          controls: PlaygroundPanel(
            title: 'Controls',
            child: Text(
              'VisirDivider has no public props in v1. Use it as a semantic section separator.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          snippet: const CodeSnippetPanel(
            title: 'Dart Snippet',
            code: 'const VisirDivider()',
          ),
        ),
      ],
    );
  }
}
