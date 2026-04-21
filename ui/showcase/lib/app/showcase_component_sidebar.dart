import 'package:flutter/material.dart';
import 'package:visir_ui/visir_ui.dart';

import 'showcase_sections.dart';

class ShowcaseComponentSidebar extends StatelessWidget {
  const ShowcaseComponentSidebar({
    super.key,
    required this.groups,
    required this.activeSectionId,
    required this.onSelected,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final List<ShowcaseSectionGroup> groups;
  final String activeSectionId;
  final ValueChanged<String> onSelected;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  bool get _isDarkMode => themeMode == ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VisirAppBar(
            key: const ValueKey('showcase-sidebar-app-bar'),
            title: 'Visir UI',
            leadings: const [],
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            trailings: [
              VisirAppBarButton.icon(
                key: const ValueKey('showcase-theme-button'),
                semanticLabel: _isDarkMode
                    ? 'Switch to light theme'
                    : 'Switch to dark theme',
                tooltip: _isDarkMode
                    ? 'Switch to light theme'
                    : 'Switch to dark theme',
                onPressed: onThemeModeChanged == null
                    ? null
                    : () {
                        onThemeModeChanged!(
                          _isDarkMode ? ThemeMode.light : ThemeMode.dark,
                        );
                      },
                icon: Icon(
                  _isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Components', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  for (final group in groups) ...[
                    Text(group.label, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    for (final sectionId in group.sectionIds)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          key: ValueKey('showcase-sidebar-$sectionId'),
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          selected: sectionId == activeSectionId,
                          selectedTileColor: theme.colorScheme.primaryContainer,
                          title: Text(showcaseSectionById(sectionId).title),
                          onTap: () => onSelected(sectionId),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
