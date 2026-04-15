import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../data/button_snippets.dart';
import '../data/icon_options.dart';
import '../playground/playground_enum_picker.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_text_field.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirButtonSection extends StatefulWidget {
  const VisirButtonSection({super.key});

  @override
  State<VisirButtonSection> createState() => _VisirButtonSectionState();
}

class _VisirButtonSectionState extends State<VisirButtonSection> {
  String _label = 'Continue';
  VisirButtonVariant _variant = VisirButtonVariant.primary;
  VisirButtonSize _size = VisirButtonSize.md;
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _enabled = true;
  String _tooltip = '';
  CuratedIconOption? _leadingIcon = curatedIconById('add');
  CuratedIconOption? _trailingIcon = curatedIconById('arrow-forward');

  String get _snippet => buildButtonSnippet(
    label: _label,
    variant: _variant,
    size: _size,
    isLoading: _isLoading,
    isExpanded: _isExpanded,
    leadingIcon: _leadingIcon,
    trailingIcon: _trailingIcon,
    tooltip: _tooltip,
    enabled: _enabled,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirButton',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Primary action button with enum-based variants, sizes, '
          'loading state, and optional icon slots. Keyboard focus styling '
          'is preserved in the live preview.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              child: SizedBox(
                width: _isExpanded ? 280 : null,
                child: VisirButton(
                  label: _label,
                  onPressed: _enabled ? () {} : null,
                  variant: _variant,
                  size: _size,
                  isLoading: _isLoading,
                  isExpanded: _isExpanded,
                  tooltip: _tooltip.trim().isEmpty ? null : _tooltip.trim(),
                  leading: _leadingIcon == null
                      ? null
                      : Icon(_leadingIcon!.iconData),
                  trailing: _trailingIcon == null
                      ? null
                      : Icon(_trailingIcon!.iconData),
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
                  label: 'Tooltip',
                  value: _tooltip,
                  hintText: 'Optional hover hint',
                  onChanged: (value) => setState(() => _tooltip = value),
                ),
                const SizedBox(height: 12),
                PlaygroundEnumPicker<VisirButtonVariant>(
                  label: 'Variant',
                  values: VisirButtonVariant.values,
                  value: _variant,
                  onChanged: (value) => setState(() => _variant = value),
                  labelBuilder: _enumLabel,
                ),
                const SizedBox(height: 12),
                PlaygroundEnumPicker<VisirButtonSize>(
                  label: 'Size',
                  values: VisirButtonSize.values,
                  value: _size,
                  onChanged: (value) => setState(() => _size = value),
                  labelBuilder: _enumLabel,
                ),
                const SizedBox(height: 12),
                _IconSelector(
                  label: 'Leading Icon',
                  selected: _leadingIcon,
                  onSelected: (icon) => setState(() => _leadingIcon = icon),
                ),
                const SizedBox(height: 12),
                _IconSelector(
                  label: 'Trailing Icon',
                  selected: _trailingIcon,
                  onSelected: (icon) => setState(() => _trailingIcon = icon),
                ),
                const SizedBox(height: 4),
                _BooleanToggle(
                  label: 'Enabled',
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
                _BooleanToggle(
                  label: 'Loading',
                  value: _isLoading,
                  onChanged: (value) => setState(() => _isLoading = value),
                ),
                _BooleanToggle(
                  label: 'Expanded',
                  value: _isExpanded,
                  onChanged: (value) => setState(() => _isExpanded = value),
                ),
              ],
            ),
          ),
          snippet: _SnippetPanel(code: _snippet),
        ),
      ],
    );
  }
}

class _SnippetPanel extends StatelessWidget {
  const _SnippetPanel({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PlaygroundPanel(
      title: 'Dart Snippet',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: SelectableText(
          code,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _BooleanToggle extends StatelessWidget {
  const _BooleanToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
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
