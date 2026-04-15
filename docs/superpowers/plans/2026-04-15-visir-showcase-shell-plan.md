# Visir Showcase Shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the editorial Visir UI showcase shell with a custom light theme, hero, jump navigation, and labeled placeholder sections before filling in real components.

**Architecture:** Compose a single `ShowcasePage` powered by `SingleChildScrollView` and a column of placeholder sections while `ShowcaseTheme.build()` injects the approved light palette into `MaterialApp`. Jump navigation targets `GlobalKey`s built from a shared section list.

**Tech Stack:** Flutter (Material 3), Dart, flutter_test, Flutter web build.

---

### Task 1: Update the smoke test to track the hero and navigation copy

**Files:**
- Modify: `ui/showcase/test/showcase_smoke_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';

void main() {
  testWidgets('ShowcaseApp renders the hero and jump links',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('Visir UI'), findsOneWidget);
    expect(find.text('Live Visir component playground'), findsOneWidget);
    expect(find.text('Jump to Button'), findsOneWidget);
    expect(find.text('Jump to Input'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test ui/showcase/test/showcase_smoke_test.dart`

Expected: FAIL because the current page still renders `Component Playground` and lacks jump links.

- [ ] **Step 3: Note the failure output for reference**

Capture the failure message (missing text nodes) so we can confirm the fix once implementation completes.

### Task 2: Add theme utilities and section metadata

**Files:**
- Create: `ui/showcase/lib/app/showcase_sections.dart`
- Create: `ui/showcase/lib/app/showcase_theme.dart`

- [ ] **Step 1: Define `showcaseSectionIds` constant and helper text utilities**

```dart
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
```

- [ ] **Step 2: Build `ShowcaseTheme.build()` returning the editorial palette**

```dart
class ShowcaseTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        background: Color(0xFFF6F0E8),
        surface: Color(0xFFF6F0E8),
        onBackground: Color(0xFF17161A),
        onSurface: Color(0xFF17161A),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F0E8),
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFF17161A),
        displayColor: const Color(0xFF17161A),
      ),
    );
  }
}
```

- [ ] **Step 3: Ensure the utilities are exported for use by the page**

Import `showcase_sections.dart` inside `ShowcasePage`, and rely on `showcaseSectionKeys` when scrolling to placeholders.

### Task 3: Implement the single-page shell

**Files:**
- Modify: `ui/showcase/lib/app/showcase_app.dart`
- Modify: `ui/showcase/lib/app/showcase_page.dart`

- [ ] **Step 1: Apply `ShowcaseTheme.build()` in `ShowcaseApp`**

```dart
class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visir UI Showcase',
      debugShowCheckedModeBanner: false,
      theme: ShowcaseTheme.build(),
      home: const ShowcasePage(),
    );
  }
}
```

- [ ] **Step 2: Build hero + navigation layout**

Inside `ShowcasePage`, wrap content in a `SingleChildScrollView`. Add:

* Hero heading: `Visir UI`.
* Subtitle: `Live Visir component playground`.
* Jump row of `TextButton`s for `button` and `input` that call `_jumpTo`.

- [ ] **Step 3: Render labeled placeholders**

For every id in `showcaseSectionIds`, render a container with the section title, the `sectionPlaceholderDescription(id)` text, and a gray panel that says “Component area coming soon.” Each container uses the corresponding key from `showcaseSectionKeys`.

- [ ] **Step 4: Wire jump buttons to the placeholder keys**

Each jump button should call `Scrollable.ensureVisible` on the matching `GlobalKey` so the anchor scrolls to its section.

### Task 4: Verify and ship

**Files:**
- No code changes; rerun verification commands.

- [ ] **Step 1: Run the smoke test and expect success**

Run: `flutter test ui/showcase/test/showcase_smoke_test.dart`

Expected: PASS now that the hero and jump copy exist.

- [ ] **Step 2: Build the web release**

Run: `cd ui/showcase && flutter build web --release`

Expected: SUCCESS.

- [ ] **Step 3: Commit the changes**

```bash
git add ui/showcase/lib/app/showcase_app.dart \
  ui/showcase/lib/app/showcase_page.dart \
  ui/showcase/lib/app/showcase_sections.dart \
  ui/showcase/lib/app/showcase_theme.dart \
  ui/showcase/test/showcase_smoke_test.dart \
  docs/superpowers/plans/2026-04-15-visir-showcase-shell-plan.md \
  docs/superpowers/specs/2026-04-15-visir-showcase-shell-design.md
git commit -m "feat: add visir showcase shell"
```
