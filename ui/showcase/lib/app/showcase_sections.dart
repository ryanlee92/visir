import 'package:flutter/material.dart';

import '../sections/visir_badge_section.dart';
import '../sections/visir_app_bar_section.dart';
import '../sections/visir_button_section.dart';
import '../sections/visir_card_section.dart';
import '../sections/visir_divider_section.dart';
import '../sections/visir_empty_state_section.dart';
import '../sections/visir_icon_button_section.dart';
import '../sections/visir_input_section.dart';
import '../sections/visir_section_section.dart';
import '../sections/visir_spinner_section.dart';

const List<String> showcaseSectionIds = [
  'button',
  'icon-button',
  'input',
  'app-bar',
  'card',
  'badge',
  'section',
  'divider',
  'spinner',
  'empty-state',
];

const Set<String> _featuredShowcaseJumpSectionIdSet = {'button', 'input'};

final List<String> featuredShowcaseJumpSectionIds = [
  for (final id in showcaseSectionIds)
    if (_featuredShowcaseJumpSectionIdSet.contains(id)) id,
];

const List<ShowcaseSectionGroup> showcaseSectionGroups = [
  ShowcaseSectionGroup(label: 'Actions', sectionIds: ['button', 'icon-button']),
  ShowcaseSectionGroup(label: 'Forms', sectionIds: ['input']),
  ShowcaseSectionGroup(label: 'Navigation', sectionIds: ['app-bar']),
  ShowcaseSectionGroup(label: 'Surfaces', sectionIds: ['card', 'section']),
  ShowcaseSectionGroup(label: 'Feedback', sectionIds: ['divider', 'spinner']),
  ShowcaseSectionGroup(label: 'Status', sectionIds: ['badge', 'empty-state']),
];

@immutable
class ShowcaseSectionGroup {
  const ShowcaseSectionGroup({required this.label, required this.sectionIds});

  final String label;
  final List<String> sectionIds;
}

@immutable
class ShowcaseSectionEntry {
  const ShowcaseSectionEntry({
    required this.id,
    required this.title,
    required this.groupLabel,
    required this.builder,
  });

  final String id;
  final String title;
  final String groupLabel;
  final WidgetBuilder builder;
}

Key showcaseSidebarSectionKey(String sectionId) {
  if (sectionId == 'app-bar') {
    return const ValueKey('showcase-sidebar-component-app-bar');
  }

  return ValueKey('showcase-sidebar-$sectionId');
}

final List<ShowcaseSectionEntry> showcaseSections = [
  ShowcaseSectionEntry(
    id: 'button',
    title: 'VisirButton',
    groupLabel: 'Actions',
    builder: (_) => const VisirButtonSection(),
  ),
  ShowcaseSectionEntry(
    id: 'icon-button',
    title: 'VisirIconButton',
    groupLabel: 'Actions',
    builder: (_) => const VisirIconButtonSection(),
  ),
  ShowcaseSectionEntry(
    id: 'input',
    title: 'VisirInput',
    groupLabel: 'Forms',
    builder: (_) => const VisirInputSection(),
  ),
  ShowcaseSectionEntry(
    id: 'app-bar',
    title: 'VisirAppBar',
    groupLabel: 'Navigation',
    builder: (_) => const VisirAppBarSection(),
  ),
  ShowcaseSectionEntry(
    id: 'card',
    title: 'VisirCard',
    groupLabel: 'Surfaces',
    builder: (_) => const VisirCardSection(),
  ),
  ShowcaseSectionEntry(
    id: 'badge',
    title: 'VisirBadge',
    groupLabel: 'Status',
    builder: (_) => const VisirBadgeSection(),
  ),
  ShowcaseSectionEntry(
    id: 'section',
    title: 'VisirSection',
    groupLabel: 'Surfaces',
    builder: (_) => const VisirSectionSection(),
  ),
  ShowcaseSectionEntry(
    id: 'divider',
    title: 'VisirDivider',
    groupLabel: 'Feedback',
    builder: (_) => const VisirDividerSection(),
  ),
  ShowcaseSectionEntry(
    id: 'spinner',
    title: 'VisirSpinner',
    groupLabel: 'Feedback',
    builder: (_) => const VisirSpinnerSection(),
  ),
  ShowcaseSectionEntry(
    id: 'empty-state',
    title: 'VisirEmptyState',
    groupLabel: 'Status',
    builder: (_) => const VisirEmptyStateSection(),
  ),
];

ShowcaseSectionEntry showcaseSectionById(String id) {
  return showcaseSections.firstWhere((entry) => entry.id == id);
}

String prettySectionTitle(String id) {
  return id
      .split('-')
      .map(
        (word) =>
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
      )
      .join(' ');
}

String sectionPlaceholderDescription(String id) {
  return 'Placeholder for ${prettySectionTitle(id)} components.';
}
