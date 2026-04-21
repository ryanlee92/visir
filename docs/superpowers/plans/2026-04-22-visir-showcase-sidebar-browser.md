# Visir Showcase Sidebar Browser Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current scroll-based showcase page with a grouped sidebar browser that switches between component demos while preserving each section's own state.

**Architecture:** `ShowcasePage` will become a two-pane shell with a sidebar on the left and a single active component demo on the right. A small registry will define every component's id, display title, group, and widget builder so the shell can render the sidebar without hardcoding section logic. Existing section widgets remain the owners of their own preview, controls, and snippet state; the page only chooses which one is active.

**Tech Stack:** Flutter, widget tests, `visir_ui`, `visir_ui_showcase`

---

### Task 1: Add a component registry and sidebar browser shell

**Files:**
- Modify: `ui/showcase/lib/app/showcase_sections.dart`
- Modify: `ui/showcase/lib/app/showcase_page.dart`
- Create: `ui/showcase/lib/app/showcase_component_sidebar.dart`

- [ ] **Step 1: Add failing tests for the new browser shell**

Add widget coverage in `ui/showcase/test/showcase_page_test.dart` for the sidebar and switching behavior. Use the current app shell and assert that the sidebar exposes the grouped component names and that selecting a different item swaps the visible section.

```dart
testWidgets('ShowcaseApp renders grouped component sidebar', (tester) async {
  await tester.pumpWidget(const ShowcaseApp());
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('Actions'), findsOneWidget);
  expect(find.text('Forms'), findsOneWidget);
  expect(find.text('Surfaces'), findsOneWidget);
  expect(find.text('Feedback'), findsOneWidget);
  expect(find.text('Status'), findsOneWidget);
  expect(find.text('VisirButton'), findsOneWidget);
  expect(find.text('VisirEmptyState'), findsOneWidget);
});

testWidgets('ShowcaseApp switches the active section from the sidebar', (
  tester,
) async {
  await tester.pumpWidget(const ShowcaseApp());
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('VisirButton'), findsOneWidget);
  expect(find.text('VisirInput'), findsNothing);

  await tester.tap(find.text('VisirInput'));
  await tester.pump();

  expect(find.text('VisirInput'), findsOneWidget);
  expect(find.text('VisirButton'), findsNothing);
});
```

- [ ] **Step 2: Run the showcase tests and confirm they fail**

Run: `flutter test test/showcase_page_test.dart`
Expected: FAIL because `ShowcasePage` still renders the old scroll-and-jump layout and no grouped sidebar exists yet.

- [ ] **Step 3: Implement the registry and sidebar shell**

Update `ui/showcase/lib/app/showcase_sections.dart` to define a lightweight registry type and grouped metadata. Keep the existing `prettySectionTitle()` helper, but replace the implicit flat list as the source of truth for the page shell.

```dart
import 'package:flutter/widgets.dart';
import '../sections/visir_badge_section.dart';
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
  'card',
  'badge',
  'section',
  'divider',
  'spinner',
  'empty-state',
];

const List<ShowcaseSectionGroup> showcaseSectionGroups = [
  ShowcaseSectionGroup(
    label: 'Actions',
    sectionIds: ['button', 'icon-button'],
  ),
  ShowcaseSectionGroup(
    label: 'Forms',
    sectionIds: ['input'],
  ),
  ShowcaseSectionGroup(
    label: 'Surfaces',
    sectionIds: ['card', 'section'],
  ),
  ShowcaseSectionGroup(
    label: 'Feedback',
    sectionIds: ['divider', 'spinner'],
  ),
  ShowcaseSectionGroup(
    label: 'Status',
    sectionIds: ['badge', 'empty-state'],
  ),
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
```

Create `ui/showcase/lib/app/showcase_component_sidebar.dart` with a responsive sidebar widget that renders the grouped list and calls `onSelected` when an item is tapped.

```dart
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final group in groups) ...[
          Text(group.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          for (final sectionId in group.sectionIds)
            ListTile(
              title: Text(prettySectionTitle(sectionId)),
              selected: sectionId == activeSectionId,
              onTap: () => onSelected(sectionId),
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
```

Rewrite `ui/showcase/lib/app/showcase_page.dart` so the page uses a `Row` with a sidebar and main panel. Keep the app bar and theme toggle, but remove the hero/jump-link scroll content. A narrow-width fallback can be a horizontal selector above the main content if needed, but the main shell should still be selection-driven.

```dart
class _ShowcasePageState extends State<ShowcasePage> {
  String _activeSectionId = showcaseSectionIds.first;

  void _selectSection(String id) {
    if (_activeSectionId == id) return;
    setState(() => _activeSectionId = id);
  }

  Widget _buildActiveSection() {
    return showcaseSectionById(_activeSectionId).builder(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visirTheme = VisirTheme.of(context);

    return Scaffold(
      appBar: VisirAppBar(...),
      body: SafeArea(
        top: false,
        child: Row(
          children: [
            SizedBox(
              width: 280,
              child: ShowcaseComponentSidebar(
                groups: showcaseSectionGroups,
                activeSectionId: _activeSectionId,
                onSelected: _selectSection,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ...,
                    vertical: ...,
                  ),
                  child: _buildActiveSection(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Keep the section widgets themselves unchanged in this task.

- [ ] **Step 4: Run the showcase tests and confirm they pass**

Run: `flutter test test/showcase_page_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit the core browser shell**

```bash
git add ui/showcase/lib/app/showcase_sections.dart ui/showcase/lib/app/showcase_page.dart ui/showcase/lib/app/showcase_component_sidebar.dart ui/showcase/test/showcase_page_test.dart
git commit -m "feat: add grouped showcase sidebar browser"
```

### Task 2: Update compact fallback and verify all components remain reachable

**Files:**
- Modify: `ui/showcase/lib/app/showcase_page.dart`
- Modify: `ui/showcase/test/showcase_page_test.dart`
- Modify: `ui/showcase/test/sections/supporting_sections_test.dart`

- [ ] **Step 1: Add failing tests for the compact fallback**

Add one widget test that constrains the page width and verifies the sidebar still exposes the component list in a compact form. The test should confirm all registered component titles are reachable somewhere in the rendered tree.

```dart
testWidgets('ShowcaseApp compact layout still exposes all components', (
  tester,
) async {
  tester.view.physicalSize = const Size(480, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const ShowcaseApp());
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.text('VisirButton'), findsOneWidget);
  expect(find.text('VisirIconButton'), findsOneWidget);
  expect(find.text('VisirInput'), findsOneWidget);
  expect(find.text('VisirCard'), findsOneWidget);
  expect(find.text('VisirBadge'), findsOneWidget);
  expect(find.text('VisirSection'), findsOneWidget);
  expect(find.text('VisirDivider'), findsOneWidget);
  expect(find.text('VisirSpinner'), findsOneWidget);
  expect(find.text('VisirEmptyState'), findsOneWidget);
});
```

- [ ] **Step 2: Run the compact-layout test and confirm it fails**

Run: `flutter test test/showcase_page_test.dart`
Expected: FAIL until the compact fallback is implemented.

- [ ] **Step 3: Implement the compact fallback and tighten the page test coverage**

Update `ShowcasePage` so widths below the chosen breakpoint do not waste the full 280px sidebar width. Use a compact selector that still exposes all sections and preserves the same `onSelected` logic.

A practical implementation is to branch on `MediaQuery.sizeOf(context).width`:

```dart
final isCompact = MediaQuery.sizeOf(context).width < 900;

if (isCompact) {
  return Column(
    children: [
      ShowcaseComponentSidebar(...),
      Expanded(child: _buildMainPane()),
    ],
  );
}

return Row(
  children: [
    SizedBox(width: 280, child: ShowcaseComponentSidebar(...)),
    Expanded(child: _buildMainPane()),
  ],
);
```

If the compact variant uses a horizontal selector instead of a vertical list, keep the same registry and selection behavior; do not create a second source of truth.

Update `ui/showcase/test/sections/supporting_sections_test.dart` only if the new shell changes how the supporting sections are exposed. Keep the assertions aligned with the active-component model.

- [ ] **Step 4: Run the showcase tests and confirm they pass**

Run: `flutter test`
Expected: PASS.

- [ ] **Step 5: Commit the responsive fallback update**

```bash
git add ui/showcase/lib/app/showcase_page.dart ui/showcase/test/showcase_page_test.dart ui/showcase/test/sections/supporting_sections_test.dart
git commit -m "feat: add responsive fallback for showcase sidebar"
```

### Task 3: Final verification

**Files:**
- Verify: `ui/showcase/lib/app/showcase_sections.dart`
- Verify: `ui/showcase/lib/app/showcase_page.dart`
- Verify: `ui/showcase/lib/app/showcase_component_sidebar.dart`
- Verify: `ui/showcase/test/showcase_page_test.dart`
- Verify: `ui/showcase/test/sections/supporting_sections_test.dart`

- [ ] **Step 1: Run the full showcase suite**

Run: `flutter test` in `ui/showcase`
Expected: PASS.

- [ ] **Step 2: Review the final diff**

Run: `git diff --stat`
Expected: only the showcase browser files and their tests changed.
