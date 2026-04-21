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
  String _title = 'Project Overview';
  bool _showLeading = true;
  _AppBarIconOption _leadingOption = _appBarLeadingOptions.first;
  bool _showSearchAction = true;
  bool _showMoreAction = true;
  bool _showAddAction = false;
  bool _showDivider = true;

  String get _safeTitle {
    final value = _title.trim();
    return value.isEmpty ? 'Project Overview' : value;
  }

  List<VisirAppBarButton> get _leadings {
    if (!_showLeading) {
      return const [];
    }

    return [
      VisirAppBarButton.icon(
        icon: Icon(_leadingOption.icon),
        semanticLabel: _leadingOption.semanticLabel,
        onPressed: () {},
      ),
    ];
  }

  List<VisirAppBarButton> get _trailings {
    final trailings = <VisirAppBarButton>[];

    if (_showSearchAction) {
      trailings.add(
        VisirAppBarButton.icon(
          icon: const Icon(Icons.search),
          semanticLabel: 'Search',
          onPressed: () {},
        ),
      );
    }

    if (_showMoreAction) {
      if (_showDivider && trailings.isNotEmpty) {
        trailings.add(const VisirAppBarButton.divider());
      }

      trailings.add(
        VisirAppBarButton.icon(
          icon: const Icon(Icons.more_horiz),
          semanticLabel: 'More options',
          onPressed: () {},
        ),
      );
    }

    if (_showAddAction) {
      if (_showDivider && trailings.isNotEmpty) {
        trailings.add(const VisirAppBarButton.divider());
      }

      trailings.add(
        VisirAppBarButton.icon(
          icon: const Icon(Icons.add),
          semanticLabel: 'Add',
          onPressed: () {},
        ),
      );
    }

    return trailings;
  }

  String get _snippet {
    final leadings = <String>[];
    if (_showLeading) {
      leadings.add(
        _buildButtonSnippet(
          icon: _leadingOption,
          semanticLabel: _leadingOption.semanticLabel,
        ),
      );
    }

    final trailings = <String>[];
    if (_showSearchAction) {
      trailings.add(
        _buildButtonSnippet(
          icon: _appBarTrailingOptions.first,
          semanticLabel: _appBarTrailingOptions.first.semanticLabel,
        ),
      );
    }
    if (_showMoreAction) {
      if (_showDivider && trailings.isNotEmpty) {
        trailings.add('VisirAppBarButton.divider(),');
      }
      trailings.add(
        _buildButtonSnippet(
          icon: _appBarTrailingOptions[1],
          semanticLabel: _appBarTrailingOptions[1].semanticLabel,
        ),
      );
    }
    if (_showAddAction) {
      if (_showDivider && trailings.isNotEmpty) {
        trailings.add('VisirAppBarButton.divider(),');
      }
      trailings.add(
        _buildButtonSnippet(
          icon: _appBarTrailingOptions[2],
          semanticLabel: _appBarTrailingOptions[2].semanticLabel,
        ),
      );
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
                          backgroundColor: theme.colorScheme.surface,
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
                Text('Leading', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                PlaygroundToggle(
                  label: 'Show leading button',
                  value: _showLeading,
                  onChanged: (value) => setState(() => _showLeading = value),
                ),
                if (_showLeading) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in _appBarLeadingOptions)
                        ChoiceChip(
                          label: Text(option.label),
                          avatar: Icon(option.icon, size: 16),
                          selected: _leadingOption.id == option.id,
                          onSelected: (_) =>
                              setState(() => _leadingOption = option),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text('Trailing', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
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

  String _buildButtonSnippet({
    required _AppBarIconOption icon,
    required String semanticLabel,
  }) {
    return 'VisirAppBarButton.icon('
        '\n      icon: ${icon.iconExpression},'
        '\n      semanticLabel: ${dartStringLiteral(semanticLabel)},'
        '\n      onPressed: () {},'
        '\n    ),';
  }
}

class _AppBarIconOption {
  const _AppBarIconOption({
    required this.id,
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.iconExpression,
  });

  final String id;
  final String label;
  final String semanticLabel;
  final IconData icon;
  final String iconExpression;
}

const List<_AppBarIconOption> _appBarLeadingOptions = [
  _AppBarIconOption(
    id: 'back',
    label: 'Back',
    semanticLabel: 'Back',
    icon: Icons.arrow_back,
    iconExpression: 'Icons.arrow_back',
  ),
  _AppBarIconOption(
    id: 'close',
    label: 'Close',
    semanticLabel: 'Close',
    icon: Icons.close,
    iconExpression: 'Icons.close',
  ),
  _AppBarIconOption(
    id: 'menu',
    label: 'Menu',
    semanticLabel: 'Open navigation',
    icon: Icons.menu,
    iconExpression: 'Icons.menu',
  ),
];

const List<_AppBarIconOption> _appBarTrailingOptions = [
  _AppBarIconOption(
    id: 'search',
    label: 'Search',
    semanticLabel: 'Search',
    icon: Icons.search,
    iconExpression: 'Icons.search',
  ),
  _AppBarIconOption(
    id: 'more',
    label: 'More',
    semanticLabel: 'More options',
    icon: Icons.more_horiz,
    iconExpression: 'Icons.more_horiz',
  ),
  _AppBarIconOption(
    id: 'add',
    label: 'Add',
    semanticLabel: 'Add',
    icon: Icons.add,
    iconExpression: 'Icons.add',
  ),
];
