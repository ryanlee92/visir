import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../data/button_snippets.dart';
import '../data/icon_options.dart';
import '../playground/playground_enum_picker.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_text_field.dart';
import '../playground/playground_toggle.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirIconButtonSection extends StatefulWidget {
  const VisirIconButtonSection({super.key});

  @override
  State<VisirIconButtonSection> createState() => _VisirIconButtonSectionState();
}

class _VisirIconButtonSectionState extends State<VisirIconButtonSection> {
  CuratedIconOption _icon =
      curatedIconById('search') ?? curatedIconOptions.first;
  VisirButtonVariant _variant = VisirButtonVariant.secondary;
  VisirButtonSize _size = VisirButtonSize.md;
  VisirButtonBorder _border = VisirButtonBorder.none;
  bool _showShadow = false;
  String _tooltip = '';
  bool _enabled = true;

  String get _snippet => buildIconButtonSnippet(
    icon: _icon,
    semanticLabel: _icon.label,
    variant: _variant,
    size: _size,
    border: _border,
    showShadow: _showShadow,
    tooltip: _tooltip,
    enabled: _enabled,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirIconButton',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Compact action button for icon-led actions with enforced '
          'semantic labeling and keyboard focus support.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              child: VisirIconButton(
                icon: Icon(_icon.iconData),
                semanticLabel: _icon.label,
                onPressed: _enabled ? () {} : null,
                variant: _variant,
                size: _size,
                border: _border,
                showShadow: _showShadow,
                tooltip: _tooltip.trim().isEmpty ? null : _tooltip.trim(),
              ),
            ),
          ),
          controls: PlaygroundPanel(
            title: 'Controls',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                _BorderSelector(
                  value: _border,
                  onChanged: (value) => setState(() => _border = value),
                ),
                const SizedBox(height: 12),
                Text('Icon', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in curatedIconOptions)
                      ChoiceChip(
                        label: Text(option.label),
                        avatar: Icon(option.iconData, size: 16),
                        selected: _icon.id == option.id,
                        onSelected: (_) => setState(() => _icon = option),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                PlaygroundToggle(
                  label: 'Enabled',
                  value: _enabled,
                  onChanged: (value) => setState(() => _enabled = value),
                ),
                PlaygroundToggle(
                  label: 'Shadow',
                  value: _showShadow,
                  onChanged: (value) => setState(() => _showShadow = value),
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

class _BorderSelector extends StatelessWidget {
  const _BorderSelector({required this.value, required this.onChanged});

  final VisirButtonBorder value;
  final ValueChanged<VisirButtonBorder> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Border', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in VisirButtonBorder.values)
              ChoiceChip(
                label: Text(_enumLabel(option)),
                selected: value == option,
                onSelected: (_) => onChanged(option),
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
