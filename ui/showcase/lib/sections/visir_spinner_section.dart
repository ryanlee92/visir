import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../playground/code_snippet_panel.dart';
import '../playground/playground_enum_picker.dart';
import '../playground/playground_panel.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirSpinnerSection extends StatefulWidget {
  const VisirSpinnerSection({super.key});

  @override
  State<VisirSpinnerSection> createState() => _VisirSpinnerSectionState();
}

class _VisirSpinnerSectionState extends State<VisirSpinnerSection> {
  VisirSpinnerSize _size = VisirSpinnerSize.md;
  VisirSpinnerTone _tone = VisirSpinnerTone.primary;

  String get _snippet {
    final arguments = <String>[
      if (_size != VisirSpinnerSize.md) 'size: VisirSpinnerSize.${_size.name},',
      if (_tone != VisirSpinnerTone.primary)
        'tone: VisirSpinnerTone.${_tone.name},',
    ];
    final buffer = StringBuffer()..writeln('VisirSpinner(');
    for (final argument in arguments) {
      buffer.writeln('  $argument');
    }
    buffer.write(')');
    return arguments.isEmpty ? 'const VisirSpinner()' : buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirSpinner',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Loading indicator with enum-based size and tone options.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              minHeight: 130,
              child: VisirSpinner(size: _size, tone: _tone),
            ),
          ),
          controls: PlaygroundPanel(
            title: 'Controls',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlaygroundEnumPicker<VisirSpinnerSize>(
                  label: 'Size',
                  values: VisirSpinnerSize.values,
                  value: _size,
                  onChanged: (value) => setState(() => _size = value),
                  labelBuilder: _enumLabel,
                ),
                const SizedBox(height: 12),
                PlaygroundEnumPicker<VisirSpinnerTone>(
                  label: 'Tone',
                  values: VisirSpinnerTone.values,
                  value: _tone,
                  onChanged: (value) => setState(() => _tone = value),
                  labelBuilder: _enumLabel,
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

String _enumLabel(Enum value) {
  final name = value.name;
  return name[0].toUpperCase() + name.substring(1);
}
