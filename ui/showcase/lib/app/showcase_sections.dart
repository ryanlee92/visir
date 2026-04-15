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

const List<String> featuredShowcaseJumpSectionIds = [
  'button',
  'input',
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
