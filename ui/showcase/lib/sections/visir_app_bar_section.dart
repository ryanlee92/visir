import 'package:flutter/material.dart';

import 'package:visir_ui/visir_ui.dart';
import '../data/snippet_utils.dart';
import '../playground/code_snippet_panel.dart';
import '../playground/playground_panel.dart';
import '../playground/playground_text_field.dart';
import '../playground/playground_toggle.dart';
import '../playground/preview_frame.dart';
import 'showcase_section_layout.dart';

class VisirAppBarSection extends StatefulWidget {
  const VisirAppBarSection({super.key});

  @override
  State<VisirAppBarSection> createState() => _VisirAppBarSectionState();
}

class _VisirAppBarSectionState extends State<VisirAppBarSection> {
  final _AppBarButtonConfig _leadingConfig = _AppBarButtonConfig(
    label: 'Leading',
    iconOption: _appBarLeadingOptions.first,
    tooltip: '',
    enabled: true,
    variant: _AppBarButtonVariant.icon,
    childLabel: 'Back',
  );

  final _AppBarButtonConfig _searchConfig = _AppBarButtonConfig(
    label: 'Search',
    iconOption: _appBarTrailingOptions[0],
    tooltip: '',
    enabled: true,
    variant: _AppBarButtonVariant.icon,
    childLabel: 'Search',
  );

  final _AppBarButtonConfig _moreConfig = _AppBarButtonConfig(
    label: 'More',
    iconOption: _appBarTrailingOptions[1],
    tooltip: '',
    enabled: true,
    variant: _AppBarButtonVariant.icon,
    childLabel: 'More',
  );

  final _AppBarButtonConfig _addConfig = _AppBarButtonConfig(
    label: 'Add',
    iconOption: _appBarTrailingOptions[2],
    tooltip: '',
    enabled: true,
    variant: _AppBarButtonVariant.icon,
    childLabel: 'Add',
  );

  String _title = 'Project Overview';
  _AppBarBackgroundOption _backgroundOption = _appBarBackgroundOptions.first;
  bool _showLeading = true;
  bool _showSearchAction = true;
  bool _showMoreAction = true;
  bool _showAddAction = false;
  bool _showDivider = true;
  _AppBarSlot _selectedTrailingSlot = _AppBarSlot.search;

  String get _safeTitle {
    final value = _title.trim();
    return value.isEmpty ? 'Project Overview' : value;
  }

  Color? _backgroundColor(ThemeData theme) => _backgroundOption.resolve(theme);

  _AppBarButtonConfig get _selectedTrailingConfig =>
      switch (_selectedTrailingSlot) {
        _AppBarSlot.search => _searchConfig,
        _AppBarSlot.more => _moreConfig,
        _AppBarSlot.add => _addConfig,
      };

  List<VisirAppBarButton> get _leadings {
    if (!_showLeading) {
      return const [];
    }

    return [_buildButton(_leadingConfig)];
  }

  List<VisirAppBarButton> get _trailings {
    final trailings = <VisirAppBarButton>[];

    if (_showSearchAction) {
      trailings.add(_buildButton(_searchConfig));
    }

    if (_showMoreAction) {
      if (_showDivider && trailings.isNotEmpty) {
        trailings.add(const VisirAppBarButton.divider());
      }

      trailings.add(_buildButton(_moreConfig));
    }

    if (_showAddAction) {
      if (_showDivider && trailings.isNotEmpty) {
        trailings.add(const VisirAppBarButton.divider());
      }

      trailings.add(_buildButton(_addConfig));
    }

    return trailings;
  }

  String get _snippet {
    final leadings = <String>[];
    if (_showLeading) {
      leadings.add(_buildButtonSnippet(_leadingConfig));
    }

    final trailings = <String>[];
    if (_showSearchAction) {
      trailings.add(_buildButtonSnippet(_searchConfig));
    }
    if (_showMoreAction) {
      if (_showDivider && trailings.isNotEmpty) {
        trailings.add('VisirAppBarButton.divider(),');
      }
      trailings.add(_buildButtonSnippet(_moreConfig));
    }
    if (_showAddAction) {
      if (_showDivider && trailings.isNotEmpty) {
        trailings.add('VisirAppBarButton.divider(),');
      }
      trailings.add(_buildButtonSnippet(_addConfig));
    }

    final buffer = StringBuffer()..writeln('VisirAppBar(');
    buffer.writeln("  title: ${dartStringLiteral(_safeTitle)},");

    buffer.writeln('  leadings: [');
    for (final line in leadings) {
      buffer.writeln('    $line');
    }
    buffer.writeln('  ],');

    buffer.writeln('  trailings: [');
    for (final line in trailings) {
      buffer.writeln('    $line');
    }
    buffer.writeln('  ],');

    if (_backgroundOption.includeBackgroundColor) {
      buffer.writeln(
        '  backgroundColor: ${_backgroundOption.backgroundColorExpression},',
      );
    }

    buffer.write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VisirAppBar',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Top-level shell app bar with leading actions, trailing actions, '
          'and an optional divider between action groups.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ShowcaseSectionLayout(
          preview: PlaygroundPanel(
            title: 'Live Preview',
            child: PreviewFrame(
              minHeight: 220,
              child: SizedBox(
                width: 420,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VisirAppBar(
                          title: _safeTitle,
                          leadings: _leadings,
                          trailings: _trailings,
                          backgroundColor: _backgroundColor(theme),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: theme.colorScheme.surfaceContainerLowest,
                          child: Text(
                            'App content area',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
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
                Text('Background', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in _appBarBackgroundOptions)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: _backgroundOption.id == option.id,
                        onSelected: (_) =>
                            setState(() => _backgroundOption = option),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _ButtonEditor(
                  title: 'Leading',
                  config: _leadingConfig,
                  iconOptions: _appBarLeadingOptions,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 12),
                Text('Trailing action', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final slot in _AppBarSlot.values)
                      ChoiceChip(
                        label: Text(slot.label),
                        selected: _selectedTrailingSlot == slot,
                        onSelected: (_) =>
                            setState(() => _selectedTrailingSlot = slot),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _ButtonEditor(
                  title: _selectedTrailingConfig.label,
                  config: _selectedTrailingConfig,
                  iconOptions: _appBarTrailingOptions,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 12),
                Text('Group behavior', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                PlaygroundToggle(
                  label: 'Show leading button',
                  value: _showLeading,
                  onChanged: (value) => setState(() => _showLeading = value),
                ),
                PlaygroundToggle(
                  label: 'Show search action',
                  value: _showSearchAction,
                  onChanged: (value) =>
                      setState(() => _showSearchAction = value),
                ),
                PlaygroundToggle(
                  label: 'Show more action',
                  value: _showMoreAction,
                  onChanged: (value) => setState(() => _showMoreAction = value),
                ),
                PlaygroundToggle(
                  label: 'Show add action',
                  value: _showAddAction,
                  onChanged: (value) => setState(() => _showAddAction = value),
                ),
                const SizedBox(height: 8),
                PlaygroundToggle(
                  label: 'Divider',
                  value: _showDivider,
                  onChanged: (value) => setState(() => _showDivider = value),
                ),
              ],
            ),
          ),
          snippet: CodeSnippetPanel(title: 'Dart Snippet', code: _snippet),
        ),
      ],
    );
  }

  VisirAppBarButton _buildButton(_AppBarButtonConfig config) {
    final semanticLabel = _safeSemanticLabel(config);
    final tooltip = _safeTooltip(config.tooltip);

    return switch (config.variant) {
      _AppBarButtonVariant.icon => VisirAppBarButton.icon(
        icon: Icon(config.iconOption.icon),
        semanticLabel: semanticLabel,
        onPressed: config.enabled ? () {} : null,
        tooltip: tooltip,
      ),
      _AppBarButtonVariant.child => VisirAppBarButton.child(
        child: Text(_safeChildLabel(config)),
        semanticLabel: semanticLabel,
        onPressed: config.enabled ? () {} : null,
        tooltip: tooltip,
      ),
    };
  }

  String _buildButtonSnippet(_AppBarButtonConfig config) {
    final semanticLabel = _safeSemanticLabel(config);
    final tooltip = _safeTooltip(config.tooltip);

    final lines = <String>[
      switch (config.variant) {
        _AppBarButtonVariant.icon => 'VisirAppBarButton.icon(',
        _AppBarButtonVariant.child => 'VisirAppBarButton.child(',
      },
    ];

    if (config.variant == _AppBarButtonVariant.icon) {
      lines.add('  icon: ${config.iconOption.iconExpression},');
    } else {
      lines.add(
        '  child: Text(${dartStringLiteral(_safeChildLabel(config))}),',
      );
    }

    lines.add('  semanticLabel: ${dartStringLiteral(semanticLabel)},');
    lines.add('  onPressed: ${config.enabled ? '() {}' : 'null'},');
    if (tooltip != null) {
      lines.add('  tooltip: ${dartStringLiteral(tooltip)},');
    }
    lines.add('),');

    return lines.join('\n');
  }

  String _safeSemanticLabel(_AppBarButtonConfig config) {
    final value = config.childLabel.trim();
    return value.isEmpty ? config.label : value;
  }

  String? _safeTooltip(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _safeChildLabel(_AppBarButtonConfig config) {
    final value = config.childLabel.trim();
    return value.isEmpty ? config.label : value;
  }
}

class _ButtonEditor extends StatelessWidget {
  const _ButtonEditor({
    required this.title,
    required this.config,
    required this.onChanged,
    required this.iconOptions,
  });

  final String title;
  final _AppBarButtonConfig config;
  final VoidCallback onChanged;
  final List<_AppBarIconOption> iconOptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text('Button type', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Icon'),
              selected: config.variant == _AppBarButtonVariant.icon,
              onSelected: (_) {
                config.variant = _AppBarButtonVariant.icon;
                onChanged();
              },
            ),
            ChoiceChip(
              label: const Text('Child'),
              selected: config.variant == _AppBarButtonVariant.child,
              onSelected: (_) {
                config.variant = _AppBarButtonVariant.child;
                onChanged();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        PlaygroundTextField(
          label: 'Tooltip',
          value: config.tooltip,
          hintText: 'Optional hover hint',
          onChanged: (value) {
            config.tooltip = value;
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        PlaygroundTextField(
          label: 'Child Label',
          value: config.childLabel,
          onChanged: (value) {
            config.childLabel = value;
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        PlaygroundToggle(
          label: 'Enabled',
          value: config.enabled,
          onChanged: (value) {
            config.enabled = value;
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        Text('Icon', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in iconOptions)
              ChoiceChip(
                label: Text(option.label),
                avatar: Icon(option.icon, size: 16),
                selected: config.iconOption.id == option.id,
                onSelected: (_) {
                  config.iconOption = option;
                  onChanged();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _AppBarButtonConfig {
  _AppBarButtonConfig({
    required this.label,
    required this.iconOption,
    required this.tooltip,
    required this.enabled,
    required this.variant,
    required this.childLabel,
  });

  final String label;
  _AppBarIconOption iconOption;
  String tooltip;
  bool enabled;
  _AppBarButtonVariant variant;
  String childLabel;
}

enum _AppBarButtonVariant { icon, child }

enum _AppBarSlot {
  search('Search'),
  more('More'),
  add('Add');

  const _AppBarSlot(this.label);

  final String label;
}

class _AppBarIconOption {
  const _AppBarIconOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconExpression,
  });

  final String id;
  final String label;
  final IconData icon;
  final String iconExpression;
}

class _AppBarBackgroundOption {
  const _AppBarBackgroundOption({
    required this.id,
    required this.label,
    required this.backgroundColorExpression,
  });

  final String id;
  final String label;
  final String backgroundColorExpression;

  Color? resolve(ThemeData theme) {
    return switch (id) {
      'surface' => theme.colorScheme.surface,
      'transparent' => Colors.transparent,
      _ => null,
    };
  }

  bool get includeBackgroundColor => id != 'default';
}

const List<_AppBarIconOption> _appBarLeadingOptions = [
  _AppBarIconOption(
    id: 'back',
    label: 'Back',
    icon: Icons.arrow_back,
    iconExpression: 'Icons.arrow_back',
  ),
  _AppBarIconOption(
    id: 'close',
    label: 'Close',
    icon: Icons.close,
    iconExpression: 'Icons.close',
  ),
  _AppBarIconOption(
    id: 'menu',
    label: 'Menu',
    icon: Icons.menu,
    iconExpression: 'Icons.menu',
  ),
];

const List<_AppBarIconOption> _appBarTrailingOptions = [
  _AppBarIconOption(
    id: 'search',
    label: 'Search',
    icon: Icons.search,
    iconExpression: 'Icons.search',
  ),
  _AppBarIconOption(
    id: 'more',
    label: 'More',
    icon: Icons.more_horiz,
    iconExpression: 'Icons.more_horiz',
  ),
  _AppBarIconOption(
    id: 'add',
    label: 'Add',
    icon: Icons.add,
    iconExpression: 'Icons.add',
  ),
];

const List<_AppBarBackgroundOption> _appBarBackgroundOptions = [
  _AppBarBackgroundOption(
    id: 'default',
    label: 'Default',
    backgroundColorExpression: '',
  ),
  _AppBarBackgroundOption(
    id: 'surface',
    label: 'Surface',
    backgroundColorExpression: 'Theme.of(context).colorScheme.surface',
  ),
  _AppBarBackgroundOption(
    id: 'transparent',
    label: 'Transparent',
    backgroundColorExpression: 'Colors.transparent',
  ),
];
