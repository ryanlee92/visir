import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../data/button_snippets.dart';
import '../data/icon_options.dart';
import '../playground/playground_enum_picker.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_text_field.dart';
import '../playground/preview_frame.dart';

class VisirIconButtonSection extends StatefulWidget {
  const VisirIconButtonSection({super.key});

  @override
  State<VisirIconButtonSection> createState() => _VisirIconButtonSectionState();
}

class _VisirIconButtonSectionState extends State<VisirIconButtonSection> {
  CuratedIconOption _icon =
      curatedIconById('search') ?? curatedIconOptions.first;
  String _semanticLabel = 'Search';
  VisirButtonVariant _variant = VisirButtonVariant.secondary;
  VisirButtonSize _size = VisirButtonSize.md;
  String _tooltip = '';
  bool _enabled = true;

  String get _snippet => buildIconButtonSnippet(
    icon: _icon,
    semanticLabel: _semanticLabel.trim().isEmpty ? 'Action' : _semanticLabel,
    variant: _variant,
    size: _size,
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
          'semantic labeling.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final preview = PlaygroundPanel(
              title: 'Live Preview',
              child: PreviewFrame(
                child: VisirIconButton(
                  icon: Icon(_icon.iconData),
                  semanticLabel: _semanticLabel.trim().isEmpty
                      ? 'Action'
                      : _semanticLabel.trim(),
                  onPressed: _enabled ? () {} : null,
                  variant: _variant,
                  size: _size,
                  tooltip: _tooltip.trim().isEmpty ? null : _tooltip.trim(),
                ),
              ),
            );
            final controls = PlaygroundPanel(
              title: 'Controls',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlaygroundTextField(
                    label: 'Semantic Label',
                    value: _semanticLabel,
                    onChanged: (value) =>
                        setState(() => _semanticLabel = value),
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
                  _BooleanToggle(
                    label: 'Enabled',
                    value: _enabled,
                    onChanged: (value) => setState(() => _enabled = value),
                  ),
                ],
              ),
            );
            final snippet = _SnippetPanel(code: _snippet);

            if (constraints.maxWidth >= 1080) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: preview),
                  const SizedBox(width: 16),
                  Expanded(child: controls),
                  const SizedBox(width: 16),
                  Expanded(child: snippet),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                preview,
                const SizedBox(height: 16),
                controls,
                const SizedBox(height: 16),
                snippet,
              ],
            );
          },
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

String _enumLabel(Enum value) {
  final name = value.name;
  return name[0].toUpperCase() + name.substring(1);
}
