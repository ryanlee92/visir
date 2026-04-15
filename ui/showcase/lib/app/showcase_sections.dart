const List<String> showcaseSectionIds = [
  'button',
  'icon-button',
  'input',
  'card',
  'badge',
  'section',
  'divider',
  'spinner',
  'empty-state',
];

const Set<String> _featuredShowcaseJumpSectionIdSet = {
  'button',
  'input',
};

final List<String> featuredShowcaseJumpSectionIds = [
  for (final id in showcaseSectionIds)
    if (_featuredShowcaseJumpSectionIdSet.contains(id)) id,
];

String prettySectionTitle(String id) {
  return id
      .split('-')
      .map((word) => word.isEmpty
          ? word
          : word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

String sectionPlaceholderDescription(String id) {
  return 'Placeholder for ${prettySectionTitle(id)} components.';
}
