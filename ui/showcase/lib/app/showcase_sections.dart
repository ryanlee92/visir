import 'package:flutter/material.dart';

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

final Map<String, GlobalKey> showcaseSectionKeys = {
  for (final id in showcaseSectionIds) id: GlobalKey(),
};
