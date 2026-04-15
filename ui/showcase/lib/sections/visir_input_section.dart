import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../data/icon_options.dart';
import '../data/input_snippets.dart';
import '../playground/code_snippet_panel.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_text_field.dart';
import '../playground/playground_toggle.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirInputSection extends StatefulWidget {
  const VisirInputSection({super.key});

  @override
  State<VisirInputSection> createState() => _VisirInputSectionState();
}

class _VisirInputSectionState extends State<VisirInputSection> {
  String _label = 'Email';
  String _hintText = 'name@example.com';
  String _errorText = '';
  bool _enabled = true;
  CuratedIconOption? _prefixIcon = curatedIconById('mail');
  CuratedIconOption? _suffixIcon;

  String get _snippet => buildInputSnippet(
    label: _label,
    hintText: _hintText,
    prefixIcon: _prefixIcon,
    suffixIcon: _suffixIcon,
    errorText: _errorText,
    enabled: _enabled,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirInput',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Form input with consistent labeling, hinting, validation messaging, '
          'and optional icon slots.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              child: SizedBox(
                width: 360,
                child: VisirInput(
                  label: _label.trim().isEmpty ? 'Input Label' : _label.trim(),
                  hintText: _hintText.trim().isEmpty ? null : _hintText.trim(),
                  prefix: _prefixIcon == null
                      ? null
                      : Icon(_prefixIcon!.iconData),
                  suffix: _suffixIcon == null
                      ? null
                      : Icon(_suffixIcon!.iconData),
                  errorText: _errorText.trim().isEmpty
                      ? null
                      : _errorText.trim(),
                  enabled: _enabled,
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
                  label: 'Label',
                  value: _label,
                  onChanged: (value) => setState(() => _label = value),
                ),
                const SizedBox(height: 12),
                PlaygroundTextField(
                  label: 'Hint Text',
                  value: _hintText,
                  onChanged: (value) => setState(() => _hintText = value),
                ),
                const SizedBox(height: 12),
                PlaygroundTextField(
                  label: 'Error Text',
                  value: _errorText,
                  hintText: 'Optional validation message',
                  onChanged: (value) => setState(() => _errorText = value),
                ),
                const SizedBox(height: 12),
                _IconSelector(
                  label: 'Prefix Icon',
                  selected: _prefixIcon,
                  onSelected: (icon) => setState(() => _prefixIcon = icon),
                ),
                const SizedBox(height: 12),
                _IconSelector(
                  label: 'Suffix Icon',
                  selected: _suffixIcon,
                  onSelected: (icon) => setState(() => _suffixIcon = icon),
                ),
                const SizedBox(height: 4),
                PlaygroundToggle(
                  label: 'Enabled',
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
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

class _IconSelector extends StatelessWidget {
  const _IconSelector({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final CuratedIconOption? selected;
  final ValueChanged<CuratedIconOption?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('None'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
            for (final option in curatedIconOptions)
              ChoiceChip(
                label: Text(option.label),
                avatar: Icon(option.iconData, size: 16),
                selected: selected?.id == option.id,
                onSelected: (_) => onSelected(option),
              ),
          ],
        ),
      ],
    );
  }
}
