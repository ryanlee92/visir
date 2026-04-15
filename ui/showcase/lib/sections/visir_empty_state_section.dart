import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../playground/code_snippet_panel.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_text_field.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirEmptyStateSection extends StatefulWidget {
  const VisirEmptyStateSection({super.key});

  @override
  State<VisirEmptyStateSection> createState() => _VisirEmptyStateSectionState();
}

class _VisirEmptyStateSectionState extends State<VisirEmptyStateSection> {
  String _title = 'No linked items yet';
  String _description =
      'Connect a source or create a new item to populate this area.';
  String _actionLabel = 'Create Item';

  String get _safeTitle =>
      _title.trim().isEmpty ? 'Empty state' : _title.trim();
  String get _safeDescription => _description.trim().isEmpty
      ? 'Describe what users should do next.'
      : _description.trim();
  String get _safeActionLabel =>
      _actionLabel.trim().isEmpty ? 'Create Item' : _actionLabel.trim();

  String get _snippet {
    return '''
VisirEmptyState(
  title: '${_escape(_safeTitle)}',
  description: '${_escape(_safeDescription)}',
  action: VisirButton(
    label: '${_escape(_safeActionLabel)}',
    onPressed: () {},
  ),
)''';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirEmptyState',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Empty-state messaging with a required action slot.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              minHeight: 190,
              child: SizedBox(
                width: 360,
                child: VisirEmptyState(
                  title: _safeTitle,
                  description: _safeDescription,
                  action: VisirButton(
                    label: _safeActionLabel,
                    onPressed: () {},
                    size: VisirButtonSize.sm,
                  ),
                ),
              ),
            ),
          ),
          controls: PlaygroundPanel(
            title: 'Controls',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlaygroundTextField(
                  label: 'Title',
                  value: _title,
                  onChanged: (value) => setState(() => _title = value),
                ),
                const SizedBox(height: 12),
                PlaygroundTextField(
                  label: 'Description',
                  value: _description,
                  onChanged: (value) => setState(() => _description = value),
                ),
                const SizedBox(height: 12),
                PlaygroundTextField(
                  label: 'Action Label',
                  value: _actionLabel,
                  onChanged: (value) => setState(() => _actionLabel = value),
                ),
              ],
            ),
          ),
          snippet: CodeSnippetPanel(title: 'Dart Snippet', code: _snippet),
        ),
      ],
    );
  }
}

String _escape(String value) {
  return value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
}
