import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../playground/code_snippet_panel.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_text_field.dart';
import '../playground/playground_toggle.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirSectionSection extends StatefulWidget {
  const VisirSectionSection({super.key});

  @override
  State<VisirSectionSection> createState() => _VisirSectionSectionState();
}

class _VisirSectionSectionState extends State<VisirSectionSection> {
  String _title = 'Overview';
  String _content = 'Use VisirSection to group related content blocks.';
  bool _showTitle = true;

  String get _safeTitle => _title.trim().isEmpty ? 'Overview' : _title.trim();
  String get _safeContent =>
      _content.trim().isEmpty ? 'Section content' : _content.trim();

  String get _snippet {
    final lines = <String>[
      if (_showTitle) "title: '${_escape(_safeTitle)}',",
      "child: Text('${_escape(_safeContent)}'),",
    ];
    final buffer = StringBuffer()..writeln('VisirSection(');
    for (final line in lines) {
      buffer.writeln('  $line');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirSection',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Simple wrapper for grouped content with an optional title.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              minHeight: 150,
              child: SizedBox(
                width: 360,
                child: VisirSection(
                  title: _showTitle ? _safeTitle : null,
                  child: Text(
                    _safeContent,
                    style: Theme.of(context).textTheme.bodyMedium,
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
                PlaygroundToggle(
                  label: 'Show title',
                  value: _showTitle,
                  onChanged: (value) => setState(() => _showTitle = value),
                ),
                const SizedBox(height: 4),
                PlaygroundTextField(
                  label: 'Title',
                  value: _title,
                  onChanged: (value) => setState(() => _title = value),
                ),
                const SizedBox(height: 12),
                PlaygroundTextField(
                  label: 'Content',
                  value: _content,
                  onChanged: (value) => setState(() => _content = value),
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
