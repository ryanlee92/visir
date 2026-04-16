# Lock Variant-Specific Hover Behavior in Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Capture the desired VisirButton hover weighting in automated tests so the regression cannot regress again.

**Architecture:** The tests already live under `test/ui/components`; we will augment `visir_button_test.dart` with pointer-driven widget tests that inspect the hover overlay decoration for each relevant variant without touching production code.

**Tech Stack:** Flutter widget testing (`flutter_test`), Dart, `flutter test` CLI.

---
### Task 1: Hover overlay regression tests

**Files:**
- Modify: `test/ui/components/visir_button_test.dart`
- Test: same file

- [ ] **Step 1: Write the failing tests**

```dart
  testWidgets('secondary hover uses stronger legacy-style overlay treatment', (
    tester,
  ) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);

    await gesture.addPointer(location: Offset.zero);
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: VisirButton(
          label: 'Secondary hover',
          variant: VisirButtonVariant.secondary,
          onPressed: () {},
        ),
      ),
    );

    final decorationFinder = find.descendant(
      of: find.byType(VisirButton),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox && widget.decoration is BoxDecoration,
      ),
    );
    final overlayFinder = find.byKey(
      const ValueKey('visir-button-hover-overlay'),
    );

    final beforeDecoration =
        tester.widget<DecoratedBox>(decorationFinder).decoration
            as BoxDecoration;
    final beforeOverlay = tester.widget<ColoredBox>(overlayFinder).color;

    await gesture.moveTo(tester.getCenter(find.text('Secondary hover')));
    await tester.pumpAndSettle();

    final afterDecoration =
        tester.widget<DecoratedBox>(decorationFinder).decoration
            as BoxDecoration;
    final afterOverlay = tester.widget<ColoredBox>(overlayFinder).color;

    expect(afterDecoration, isNot(beforeDecoration));
    expect(afterOverlay.opacity, greaterThan(beforeOverlay.opacity));
  });

  testWidgets('ghost and danger hover stay lighter than secondary hover', (
    tester,
  ) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);

    await gesture.addPointer(location: Offset.zero);
    await tester.pumpWidget(
      makeUiTestableWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VisirButton(
              label: 'Secondary hover',
              variant: VisirButtonVariant.secondary,
              onPressed: () {},
            ),
            VisirButton(
              label: 'Ghost hover',
              variant: VisirButtonVariant.ghost,
              onPressed: () {},
            ),
            VisirButton(
              label: 'Danger hover',
              variant: VisirButtonVariant.danger,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    Future<Color> hoverOverlayFor(String label) async {
      await gesture.moveTo(tester.getCenter(find.text(label)));
      await tester.pumpAndSettle();

      return tester.widgetList<ColoredBox>(
        find.byKey(const ValueKey('visir-button-hover-overlay')),
      ).elementAt(
        switch (label) {
          'Secondary hover' => 0,
          'Ghost hover' => 1,
          _ => 2,
        },
      ).color;
    }

    final secondaryOverlay = await hoverOverlayFor('Secondary hover');
    final ghostOverlay = await hoverOverlayFor('Ghost hover');
    final dangerOverlay = await hoverOverlayFor('Danger hover');

    expect(ghostOverlay.opacity, lessThan(secondaryOverlay.opacity));
    expect(dangerOverlay.opacity, lessThan(secondaryOverlay.opacity));
  });
```

- [ ] **Step 2: Run first regression test**

Run: `flutter test test/ui/components/visir_button_test.dart --plain-name "secondary hover uses stronger legacy-style overlay treatment"`

Expected: FAIL because the current hover treatment does not expose a dedicated overlay nor a stronger variant-specific hover.

- [ ] **Step 3: Run second regression test**

Run: `flutter test test/ui/components/visir_button_test.dart --plain-name "ghost and danger hover stay lighter than secondary hover"`

Expected: FAIL because ghost/danger hover overlays are not lighter than secondary yet.

- [ ] **Step 4: Commit the failing tests**

```bash
git add test/ui/components/visir_button_test.dart
git commit -m "test: lock visir button hover refinement behavior"
```

Plan complete and saved to `docs/superpowers/plans/2026-04-16-lock-variant-hover-tests.md`. Two execution options:

1. Subagent-Driven (recommended) - dispatch a fresh subagent per step with review checkpoints.
2. Inline Execution - execute steps in this session using the executing-plans skill for checkpoints.

Which approach should I follow?
