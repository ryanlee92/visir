import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../data/card_snippets.dart';
import '../playground/code_snippet_panel.dart';
import '../playground/playground_enum_picker.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_toggle.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirCardSection extends StatefulWidget {
  const VisirCardSection({super.key});

  @override
  State<VisirCardSection> createState() => _VisirCardSectionState();
}

class _VisirCardSectionState extends State<VisirCardSection> {
  VisirCardVariant _variant = VisirCardVariant.elevated;
  VisirCardDensity _density = VisirCardDensity.comfortable;
  VisirCardBorder _border = VisirCardBorder.none;
  bool _showShadow = true;
  bool _isInteractive = false;
  int _tapCount = 0;

  String get _snippet => buildCardSnippet(
    variant: _variant,
    density: _density,
    border: _border,
    showShadow: _showShadow,
    isInteractive: _isInteractive,
    childSnippet: "const Text('Card content')",
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirCard',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Surface container with density and variant tokens, optionally '
          'interactive for clickable content blocks.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              child: SizedBox(
                width: 360,
                child: VisirCard(
                  variant: _variant,
                  border: _border,
                  showShadow: _showShadow,
                  density: _density,
                  onTap: _isInteractive
                      ? () => setState(() => _tapCount += 1)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Revenue Snapshot',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Monthly trend is up 14.2% with strongest growth in enterprise.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_isInteractive) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Tapped $_tapCount time${_tapCount == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ],
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
                PlaygroundEnumPicker<VisirCardVariant>(
                  label: 'Variant',
                  values: VisirCardVariant.values,
                  value: _variant,
                  onChanged: (value) => setState(() => _variant = value),
                  labelBuilder: _enumLabel,
                ),
                const SizedBox(height: 12),
                PlaygroundEnumPicker<VisirCardDensity>(
                  label: 'Density',
                  values: VisirCardDensity.values,
                  value: _density,
                  onChanged: (value) => setState(() => _density = value),
                  labelBuilder: _enumLabel,
                ),
                const SizedBox(height: 4),
                _BorderSelector(
                  value: _border,
                  onChanged: (value) => setState(() => _border = value),
                ),
                const SizedBox(height: 12),
                PlaygroundToggle(
                  label: 'Shadow',
                  value: _showShadow,
                  onChanged: (value) => setState(() => _showShadow = value),
                ),
                const SizedBox(height: 12),
                PlaygroundToggle(
                  label: 'Interactive (onTap)',
                  value: _isInteractive,
                  onChanged: (value) => setState(() {
                    _isInteractive = value;
                    _tapCount = 0;
                  }),
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

class _BorderSelector extends StatelessWidget {
  const _BorderSelector({required this.value, required this.onChanged});

  final VisirCardBorder value;
  final ValueChanged<VisirCardBorder> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = VisirCardBorder.values;

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

String _enumLabel(Enum value) {
  final name = value.name;
  return name[0].toUpperCase() + name.substring(1);
}
