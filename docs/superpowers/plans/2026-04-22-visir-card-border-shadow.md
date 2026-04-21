# VisirCard Border and Shadow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional token-driven border and optional elevation shadow toggle to `VisirCard`, with borders available only for muted and outlined cards.

**Architecture:** `VisirCard` keeps the surface, padding, and interactive focus behavior it already has. The new border toggle is a small enum that resolves through `VisirTheme` tokens, while `showShadow` only gates the base elevation shadow and leaves focus treatment intact.

**Tech Stack:** Flutter, widget tests, `visir_ui`, `visir_ui_showcase`

---

### Task 1: Update `VisirCard` API and widget contracts

**Files:**
- Modify: `ui/lib/src/components/visir_card.dart`
- Modify: `test/ui/components/visir_supporting_components_test.dart`

- [ ] **Step 1: Write the failing tests**

Add focused tests that express the intended contract:

```dart
testWidgets('elevated card stays borderless by default', (tester) async {
  await tester.pumpWidget(
    makeUiTestableWidget(
      child: const VisirCard(
        variant: VisirCardVariant.elevated,
        child: Text('Elevated'),
      ),
    ),
  );

  final card = tester.widget<Container>(
    find.descendant(of: find.byType(VisirCard), matching: find.byType(Container)),
  );
  expect((card.decoration as BoxDecoration).border, isNull);
});

testWidgets('outlined card can opt into base border', (tester) async {
  await tester.pumpWidget(
    makeUiTestableWidget(
      child: const VisirCard(
        variant: VisirCardVariant.outlined,
        border: VisirCardBorder.base,
        child: Text('Outlined'),
      ),
    ),
  );

  final theme = VisirTheme.of(tester.element(find.byType(VisirCard)));
  final card = tester.widget<Container>(
    find.descendant(of: find.byType(VisirCard), matching: find.byType(Container)),
  );
  final border = (card.decoration as BoxDecoration).border! as Border;
  expect(border.top.color, theme.components.control.borders.base.color);
  expect(border.top.width, theme.components.control.borders.base.width);
});

testWidgets('shadow can be disabled without removing focus treatment', (tester) async {
  await tester.pumpWidget(
    makeUiTestableWidget(
      child: VisirCard(
        variant: VisirCardVariant.elevated,
        showShadow: false,
        onTap: () {},
        child: const Text('Focusable'),
      ),
    ),
  );

  final cardFinder = find.byType(VisirCard);
  final decorationFinder = find.descendant(
    of: cardFinder,
    matching: find.byWidgetPredicate(
      (widget) => widget is Container && widget.decoration is BoxDecoration,
    ),
  );
  final unfocused = tester.widget<Container>(decorationFinder).decoration! as BoxDecoration;
  expect(unfocused.boxShadow, isEmpty);

  final focusNode = Focus.of(tester.element(find.text('Focusable')));
  focusNode.requestFocus();
  await tester.pump();

  final focused = tester.widget<Container>(decorationFinder).decoration! as BoxDecoration;
  expect(focused.boxShadow, isNotEmpty);
});
```

- [ ] **Step 2: Run the focused test file and confirm it fails**

Run: `flutter test test/ui/components/visir_supporting_components_test.dart`
Expected: fail because `VisirCard` does not yet expose `border` or `showShadow`.

- [ ] **Step 3: Implement the minimal API and decoration changes**

Update `VisirCard` so the constructor and decoration logic become:

```dart
enum VisirCardBorder { none, base }

class VisirCard extends StatefulWidget {
  const VisirCard({
    super.key,
    required this.child,
    this.variant = VisirCardVariant.elevated,
    this.border = VisirCardBorder.none,
    this.showShadow = true,
    this.density = VisirCardDensity.comfortable,
    this.onTap,
  });
}
```

Then:
- only apply `VisirCardBorder.base` when `variant` is `muted` or `outlined`
- keep elevated cards borderless even if `border` is set
- keep focus treatment unchanged
- gate only the base elevation shadow with `showShadow`
- preserve existing padding and semantics behavior

- [ ] **Step 4: Run the widget tests and confirm they pass**

Run: `flutter test test/ui/components/visir_supporting_components_test.dart`
Expected: PASS

- [ ] **Step 5: Commit the core card change**

```bash
git add ui/lib/src/components/visir_card.dart test/ui/components/visir_supporting_components_test.dart
git commit -m "feat: add border and shadow toggles to visir card"
```

### Task 2: Update the showcase card section and snippet generation

**Files:**
- Modify: `ui/showcase/lib/sections/visir_card_section.dart`
- Modify: `ui/showcase/lib/data/card_snippets.dart`
- Modify: `ui/showcase/test/snippet_generation_test.dart`
- Modify: `ui/showcase/test/sections/content_sections_test.dart`

- [ ] **Step 1: Write the failing showcase tests**

Add coverage for the new showcase controls and snippet output:

```dart
testWidgets('card section renders border and shadow controls', (tester) async {
  await tester.pumpWidget(const ShowcaseApp());

  expect(find.text('Border'), findsWidgets);
  expect(find.text('Shadow'), findsWidgets);
});

test('card snippet includes border and shadow when requested', () {
  final code = buildCardSnippet(
    variant: VisirCardVariant.outlined,
    border: VisirCardBorder.base,
    showShadow: false,
  );

  expect(code, contains('variant: VisirCardVariant.outlined'));
  expect(code, contains('border: VisirCardBorder.base'));
  expect(code, contains('showShadow: false'));
});
```

- [ ] **Step 2: Run the showcase tests and confirm they fail**

Run: `flutter test test/sections/content_sections_test.dart test/snippet_generation_test.dart`
Expected: fail because the card section and snippet helper do not yet expose the new border/shadow contract.

- [ ] **Step 3: Update the showcase controls and snippet helper**

Change the card section to:
- expose a border selector with `none/base`
- expose a shadow toggle
- pass `border:` and `showShadow:` into the preview card
- keep the existing variant and density controls intact

Update the snippet helper to accept:

```dart
String buildCardSnippet({
  Object variant = 'elevated',
  Object density = 'comfortable',
  VisirCardBorder border = VisirCardBorder.none,
  bool showShadow = true,
  bool isInteractive = false,
  String childSnippet = "const Text('Card content')",
})
```

Emit `border:` only when it is not `none`, and emit `showShadow: false` only when the shadow toggle is disabled.

- [ ] **Step 4: Run the showcase tests and confirm they pass**

Run: `flutter test test/sections/content_sections_test.dart test/snippet_generation_test.dart`
Expected: PASS

- [ ] **Step 5: Commit the showcase update**

```bash
git add ui/showcase/lib/sections/visir_card_section.dart ui/showcase/lib/data/card_snippets.dart ui/showcase/test/snippet_generation_test.dart ui/showcase/test/sections/content_sections_test.dart
git commit -m "feat: update visir card showcase for border and shadow toggles"
```

### Task 3: Final verification

**Files:**
- Verify: `ui/lib/src/components/visir_card.dart`
- Verify: `test/ui/components/visir_supporting_components_test.dart`
- Verify: `ui/showcase/lib/sections/visir_card_section.dart`
- Verify: `ui/showcase/lib/data/card_snippets.dart`
- Verify: `ui/showcase/test/snippet_generation_test.dart`
- Verify: `ui/showcase/test/sections/content_sections_test.dart`

- [ ] **Step 1: Run the full `ui` suite**

Run: `flutter test` in `ui`
Expected: PASS

- [ ] **Step 2: Run the full showcase suite**

Run: `flutter test` in `ui/showcase`
Expected: PASS

- [ ] **Step 3: Review the final diff**

Run: `git diff --stat`
Expected: only the files listed above changed, with no unrelated edits.

