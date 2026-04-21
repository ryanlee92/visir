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
  VisirInputBorder _border = VisirInputBorder.none;
  CuratedIconOption? _suffixIcon;
  bool _isLoading = false;
  bool _showClearButton = false;
  int _maxLines = 1;
  CuratedIconOption? _leadingIcon = curatedIconById('search');

  String? get _safeLabel {
    final value = _label.trim();
    return value.isEmpty ? null : value;
  }

  String? get _safeHintText {
    final value = _hintText.trim();
    return value.isEmpty ? null : value;
  }

  String? get _safeErrorText {
    final value = _errorText.trim();
    return value.isEmpty ? null : value;
  }

  String get _snippet => buildInputSnippet(
    label: _safeLabel,
    hintText: _safeHintText,
    suffixIcon: _suffixIcon,
    leadingIcon: _leadingIcon,
    errorText: _safeErrorText,
    border: _border,
    enabled: _enabled,
    isLoading: _isLoading,
    showClearButton: _showClearButton,
    maxLines: _maxLines,
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
                  label: _safeLabel,
                  border: _border,
                  hintText: _safeHintText,
                  suffix: _suffixIcon != null
                      ? Icon(_suffixIcon!.iconData)
                      : null,
                  errorText: _safeErrorText,
                  enabled: _enabled,
                  leading: _leadingIcon != null
                      ? Icon(_leadingIcon!.iconData)
                      : null,
                  isLoading: _isLoading,
                  showClearButton: _showClearButton,
                  onClear: _showClearButton ? () {} : null,
                  maxLines: _maxLines,
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
                _BorderSelector(
                  value: _border,
                  onChanged: (value) => setState(() => _border = value),
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
                  label: 'Trailing Icon',
                  selected: _suffixIcon,
                  onSelected: (icon) => setState(() => _suffixIcon = icon),
                ),
                const SizedBox(height: 12),
                _IconSelector(
                  label: 'Leading Icon',
                  selected: _leadingIcon,
                  onSelected: (icon) => setState(() => _leadingIcon = icon),
                ),
                const SizedBox(height: 12),
                PlaygroundToggle(
                  label: 'Loading',
                  value: _isLoading,
                  onChanged: (value) => setState(() => _isLoading = value),
                ),
                PlaygroundToggle(
                  label: 'Clear Button',
                  value: _showClearButton,
                  onChanged: (value) =>
                      setState(() => _showClearButton = value),
                ),
                PlaygroundToggle(
                  label: 'Enabled',
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
                const SizedBox(height: 12),
                _LineCountSelector(
                  value: _maxLines,
                  onChanged: (value) => setState(() => _maxLines = value),
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

class _LineCountSelector extends StatelessWidget {
  const _LineCountSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [1, 2, 3];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Max Lines', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option.toString()),
                selected: value == option,
                onSelected: (_) => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _BorderSelector extends StatelessWidget {
  const _BorderSelector({required this.value, required this.onChanged});

  final VisirInputBorder value;
  final ValueChanged<VisirInputBorder> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = VisirInputBorder.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Border', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(_enumLabel(option)),
                selected: option == value,
                onSelected: (_) => onChanged(option),
              ),
          ],
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

String _enumLabel(Enum value) {
  final name = value.name;
  return name[0].toUpperCase() + name.substring(1);
}
