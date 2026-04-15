import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../playground/code_snippet_panel.dart';
import '../playground/playground_enum_picker.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_text_field.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirBadgeSection extends StatefulWidget {
  const VisirBadgeSection({super.key});

  @override
  State<VisirBadgeSection> createState() => _VisirBadgeSectionState();
}

class _VisirBadgeSectionState extends State<VisirBadgeSection> {
  String _label = 'In Review';
  VisirBadgeTone _tone = VisirBadgeTone.neutral;

  String get _snippet {
    final safeLabel = _label.trim().isEmpty ? 'Badge' : _label.trim();
    final arguments = <String>[
      "label: '$safeLabel'",
      if (_tone != VisirBadgeTone.neutral) 'tone: VisirBadgeTone.${_tone.name}',
    ];
    final buffer = StringBuffer()..writeln('VisirBadge(');
    for (final argument in arguments) {
      buffer.writeln('  $argument,');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final badgeLabel = _label.trim().isEmpty ? 'Badge' : _label.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirBadge',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Small status indicator for neutral, primary, and semantic tones.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              minHeight: 130,
              child: VisirBadge(label: badgeLabel, tone: _tone),
            ),
          ),
          controls: PlaygroundPanel(
            title: 'Controls',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlaygroundTextField(
                  label: 'Label',
                  value: _label,
                  onChanged: (value) => setState(() => _label = value),
                ),
                const SizedBox(height: 12),
                PlaygroundEnumPicker<VisirBadgeTone>(
                  label: 'Tone',
                  values: VisirBadgeTone.values,
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
