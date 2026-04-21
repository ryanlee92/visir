import 'package:flutter/material.dart';

import 'showcase_sections.dart';

class ShowcaseComponentSidebar extends StatelessWidget {
  const ShowcaseComponentSidebar({
    super.key,
    required this.groups,
    required this.activeSectionId,
    required this.onSelected,
  });

  final List<ShowcaseSectionGroup> groups;
  final String activeSectionId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
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
    );
  }
}
