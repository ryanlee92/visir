# Visir Button Color Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve `VisirButton` color readability by making `primary` foregrounds clearly readable and making `danger` more vivid crimson, without changing button structure or interaction behavior.

**Architecture:** Keep this as a button-only color refinement. Prefer updating `VisirButton` color math directly, and touch shared token values only where those exact values are already the clear source of truth for the button colors.

**Tech Stack:** Flutter, Dart, `flutter_test`

---

## File Structure

- Modify: `ui/lib/src/components/visir_button.dart`
  - Retune `primary` foreground/background contrast and `danger` color behavior without changing interaction structure.
- Modify: `ui/lib/src/foundation/visir_tokens.dart`
  - Only if the current accent/danger token values are the right source of truth for the intended refinement.
- Modify: `test/ui/components/visir_button_test.dart`
  - Add focused assertions that lock primary foreground clarity and danger vividness while preserving existing interaction coverage.

### Task 1: Lock the Intended Button Color Behavior in Tests

**Files:**
- Modify: `test/ui/components/visir_button_test.dart`

- [ ] **Step 1: Write failing tests for primary foreground clarity and danger vividness**

Add focused tests near the existing button color assertions:

```dart
testWidgets('primary button uses high-contrast white foreground', (tester) async {
  await tester.pumpWidget(
    makeUiTestableWidget(
      child: VisirButton(
        label: 'Primary',
        variant: VisirButtonVariant.primary,
        onPressed: () {},
        leading: const Icon(Icons.add),
      ),
    ),
  );

  final label = tester.widget<Text>(find.text('Primary'));
  final iconTheme = tester.widget<IconTheme>(find.byType(IconTheme).first);

  expect(label.style?.color, const Color(0xFFFFFFFF));
  expect(iconTheme.data.color, const Color(0xFFFFFFFF));
});

testWidgets('danger button fill uses vivid crimson red', (tester) async {
  await tester.pumpWidget(
    makeUiTestableWidget(
      child: VisirButton(
        label: 'Danger',
        variant: VisirButtonVariant.danger,
        onPressed: () {},
      ),
    ),
  );

  final decoration = tester.widget<DecoratedBox>(
    find.byWidgetPredicate(
      (widget) => widget is DecoratedBox && widget.decoration is BoxDecoration,
    ).first,
  ).decoration as BoxDecoration;

  expect(decoration.color, const Color(0x??......));
});
```

Use the final expected crimson value you choose in Task 2. The important thing in this step is to make the tests express the intended outcome clearly: white primary foreground and a non-muted danger fill.

- [ ] **Step 2: Run the focused button test to verify the new assertions fail**

Run: `flutter test test/ui/components/visir_button_test.dart`
Expected: FAIL because `primary` still uses `textInverse` instead of white, and `danger` still uses the current muted red treatment.

- [ ] **Step 3: Commit the red tests**

```bash
git add test/ui/components/visir_button_test.dart
git commit -m "test: lock visir button color refinement"
```

### Task 2: Retune Primary and Danger Button Colors

**Files:**
- Modify: `ui/lib/src/components/visir_button.dart`
- Modify: `ui/lib/src/foundation/visir_tokens.dart` (only if needed)
- Modify: `test/ui/components/visir_button_test.dart`

- [ ] **Step 1: Update primary foreground and background contrast**

In `ui/lib/src/components/visir_button.dart`, change the primary foreground path from:

```dart
VisirButtonVariant.primary => theme.tokens.colors.textInverse,
```

to:

```dart
VisirButtonVariant.primary => Colors.white,
```

Also deepen the primary gradient slightly by reducing the white lerp or removing it entirely if that gives cleaner contrast:

```dart
VisirButtonVariant.primary => LinearGradient(
  colors: [
    Color.lerp(colors.accent, Colors.white, isHovered ? 0.04 : 0)!,
    Color.lerp(colors.accentStrong, Colors.white, isHovered ? 0.02 : 0)!,
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
```

If a stronger result is needed, use the raw accent colors directly:

```dart
VisirButtonVariant.primary => LinearGradient(
  colors: [colors.accent, colors.accentStrong],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
),
```

Choose the smallest shift that makes white foregrounds clearly readable.

- [ ] **Step 2: Retune danger to a more vivid crimson**

If the button’s current danger treatment is best handled locally, update the danger fill in `ui/lib/src/components/visir_button.dart` from:

```dart
colors.danger.withValues(alpha: isHovered ? 0.28 : 0.22)
```

to a stronger color treatment, for example:

```dart
Color.lerp(colors.danger, Colors.redAccent, isHovered ? 0.18 : 0.1)!
    .withValues(alpha: isHovered ? 0.38 : 0.32)
```

If the root token is clearly the correct source of truth, change `danger` in `ui/lib/src/foundation/visir_tokens.dart` instead:

```dart
danger: Color(0xFFE13A5F),
```

Prefer one source of truth, not both. Keep the change as small as practical.

- [ ] **Step 3: Keep spinner and icon contrast aligned**

Confirm `_spinnerTone()` and `_foregroundColor()` still produce the intended pairing:

```dart
VisirSpinnerTone _spinnerTone() {
  return widget.variant == VisirButtonVariant.primary
      ? VisirSpinnerTone.primary
      : VisirSpinnerTone.inverse;
}
```

If the updated primary foreground is white and the spinner tone no longer matches visually, adjust `_spinnerTone()` or the underlying tone mapping only as much as needed to preserve the intended contrast.

- [ ] **Step 4: Run the focused button tests**

Run: `flutter test test/ui/components/visir_button_test.dart`
Expected: PASS

- [ ] **Step 5: Commit the color refinement**

```bash
git add ui/lib/src/components/visir_button.dart ui/lib/src/foundation/visir_tokens.dart test/ui/components/visir_button_test.dart
git commit -m "feat: refine visir button colors"
```

### Task 3: Full Verification

**Files:**
- Modify: any touched files from Tasks 1-2 if formatting requires it

- [ ] **Step 1: Format touched files**

Run: `dart format ui/lib/src/components/visir_button.dart ui/lib/src/foundation/visir_tokens.dart test/ui/components/visir_button_test.dart`
Expected: Formatter exits successfully.

- [ ] **Step 2: Run analysis**

Run: `dart analyze ui/lib test/ui`
Expected: `No issues found!`

- [ ] **Step 3: Run focused button tests**

Run: `flutter test test/ui/components/visir_button_test.dart`
Expected: PASS

- [ ] **Step 4: Run the full `ui` test suite**

Run: `flutter test test/ui`
Expected: PASS

- [ ] **Step 5: Commit any verification-driven fixes**

```bash
git add ui/lib/src/components/visir_button.dart ui/lib/src/foundation/visir_tokens.dart test/ui/components/visir_button_test.dart
git commit -m "chore: finalize visir button color refinement"
```
