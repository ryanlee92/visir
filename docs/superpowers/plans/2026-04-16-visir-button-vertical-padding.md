# Visir Button Vertical Padding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Change `VisirButton` from min-height-driven sizing to tokenized vertical-padding-driven sizing while keeping the public enum API and current interaction behavior unchanged.

**Architecture:** Update the shared control sizing token model so button sizes resolve from vertical padding, horizontal padding, and icon spacing instead of a hard min height. Then migrate `VisirButton` and its focused tests to the new token shape without broadening the change to `VisirInput` or other controls.

**Tech Stack:** Flutter, Dart, `flutter_test`

---

## File Structure

- Modify: `ui/lib/src/theme/visir_component_role_themes.dart`
  - Replace control sizing’s `height` scale with a `verticalPadding` scale and keep the convenience accessors aligned with the new token vocabulary.
- Modify: `ui/lib/src/theme/visir_theme_data.dart`
  - Update fallback control sizing values so `sm/md/lg` buttons read vertical padding from shared tokens instead of fixed heights.
- Modify: `ui/lib/src/components/visir_button.dart`
  - Remove the button min-height constraint and apply symmetric vertical padding inside the existing padded button surface.
- Modify: `test/ui/components/visir_button_test.dart`
  - Replace fixed-height expectations with token-driven vertical padding assertions and keep current interaction assertions intact.

### Task 1: Reshape Control Sizing Tokens for Button Padding

**Files:**
- Modify: `ui/lib/src/theme/visir_component_role_themes.dart`
- Modify: `ui/lib/src/theme/visir_theme_data.dart`

- [ ] **Step 1: Write the failing token-model test update**

```dart
const sizing = VisirControlSizing(
  verticalPadding: VisirControlSizeScale(sm: 6, md: 10, lg: 14),
  horizontalPadding: VisirControlSizeScale(sm: 13, md: 21, lg: 34),
  iconSpacing: 9,
  compactSpacing: 5,
);
```

And in the same test file, replace button sizing expectations that still refer to fixed height tokens with:

```dart
expect(padding.padding, const EdgeInsets.symmetric(horizontal: 13, vertical: 6));
```

for the custom `sm` sizing override.

- [ ] **Step 2: Run the focused button test to verify the current token API no longer matches**

Run: `flutter test test/ui/components/visir_button_test.dart`
Expected: FAIL because `VisirControlSizing` still expects `height`, not `verticalPadding`, and the button still renders min-height-driven sizing.

- [ ] **Step 3: Update the shared control sizing token type**

In `ui/lib/src/theme/visir_component_role_themes.dart`, change `VisirControlSizing` from:

```dart
class VisirControlSizing {
  const VisirControlSizing({
    required this.height,
    required this.horizontalPadding,
    required this.iconSpacing,
    required this.compactSpacing,
  });

  final VisirControlSizeScale height;
  final VisirControlSizeScale horizontalPadding;
  final double iconSpacing;
  final double compactSpacing;

  double heightFor(VisirButtonSize size) => height.resolve(size);
  double horizontalPaddingFor(VisirButtonSize size) =>
      horizontalPadding.resolve(size);
}
```

to:

```dart
class VisirControlSizing {
  const VisirControlSizing({
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.iconSpacing,
    required this.compactSpacing,
  });

  final VisirControlSizeScale verticalPadding;
  final VisirControlSizeScale horizontalPadding;
  final double iconSpacing;
  final double compactSpacing;

  double verticalPaddingFor(VisirButtonSize size) =>
      verticalPadding.resolve(size);
  double horizontalPaddingFor(VisirButtonSize size) =>
      horizontalPadding.resolve(size);

  VisirControlSizing copyWith({
    VisirControlSizeScale? verticalPadding,
    VisirControlSizeScale? horizontalPadding,
    double? iconSpacing,
    double? compactSpacing,
  }) {
    return VisirControlSizing(
      verticalPadding: verticalPadding ?? this.verticalPadding,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      iconSpacing: iconSpacing ?? this.iconSpacing,
      compactSpacing: compactSpacing ?? this.compactSpacing,
    );
  }
}
```

Also update equality and `hashCode` to use `verticalPadding` instead of `height`.

- [ ] **Step 4: Update fallback control sizing tokens**

In `ui/lib/src/theme/visir_theme_data.dart`, change:

```dart
sizing: VisirControlSizing(
  height: const VisirControlSizeScale(sm: 36, md: 44, lg: 52),
  horizontalPadding: VisirControlSizeScale(
    sm: tokens.spacing.md.toDouble(),
    md: tokens.spacing.lg.toDouble(),
    lg: tokens.spacing.xl.toDouble(),
  ),
  iconSpacing: tokens.spacing.sm.toDouble(),
  compactSpacing: tokens.spacing.xs.toDouble(),
),
```

to:

```dart
sizing: VisirControlSizing(
  verticalPadding: const VisirControlSizeScale(sm: 6, md: 10, lg: 14),
  horizontalPadding: VisirControlSizeScale(
    sm: tokens.spacing.md.toDouble(),
    md: tokens.spacing.lg.toDouble(),
    lg: tokens.spacing.xl.toDouble(),
  ),
  iconSpacing: tokens.spacing.sm.toDouble(),
  compactSpacing: tokens.spacing.xs.toDouble(),
),
```

- [ ] **Step 5: Run the focused button test to verify the token model compiles but the button behavior still fails**

Run: `flutter test test/ui/components/visir_button_test.dart`
Expected: FAIL because `VisirButton` still reads `heightFor(...)` and applies a min-height constraint.

- [ ] **Step 6: Commit the token-model change**

```bash
git add ui/lib/src/theme/visir_component_role_themes.dart ui/lib/src/theme/visir_theme_data.dart test/ui/components/visir_button_test.dart
git commit -m "refactor: replace button height tokens with vertical padding"
```

### Task 2: Make VisirButton Use Vertical Padding Instead of Min Height

**Files:**
- Modify: `ui/lib/src/components/visir_button.dart`
- Modify: `test/ui/components/visir_button_test.dart`

- [ ] **Step 1: Extend the failing button test to lock vertical padding behavior**

In `test/ui/components/visir_button_test.dart`, inside the existing `button sizing and border states follow control tokens` test, make the custom sizing override and padding assertion explicit:

```dart
const sizing = VisirControlSizing(
  verticalPadding: VisirControlSizeScale(sm: 6, md: 10, lg: 14),
  horizontalPadding: VisirControlSizeScale(sm: 13, md: 21, lg: 34),
  iconSpacing: 9,
  compactSpacing: 5,
);
```

and assert:

```dart
final padding = tester.widget<Padding>(smallPaddingFinder.first);
expect(
  padding.padding,
  const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
);
```

Also replace any assertion that depends on a button `minHeight` token with a size-ordering assertion only:

```dart
expect(largeHeight, greaterThan(smallHeight));
```

- [ ] **Step 2: Run the focused button test to confirm the layout still fails**

Run: `flutter test test/ui/components/visir_button_test.dart`
Expected: FAIL because the current button padding is horizontal-only and the min-height constraint is still present.

- [ ] **Step 3: Update `VisirButton` to use symmetric tokenized padding**

In `ui/lib/src/components/visir_button.dart`, replace:

```dart
final height = control.sizing.heightFor(widget.size);
final horizontalPadding = control.sizing.horizontalPaddingFor(widget.size);
```

with:

```dart
final verticalPadding = control.sizing.verticalPaddingFor(widget.size);
final horizontalPadding = control.sizing.horizontalPaddingFor(widget.size);
```

Replace the inner padding:

```dart
padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
```

with:

```dart
padding: EdgeInsets.symmetric(
  horizontal: horizontalPadding,
  vertical: verticalPadding,
),
```

And remove the min-height wrapper:

```dart
child: ConstrainedBox(
  constraints: BoxConstraints(minHeight: height),
  child: MergeSemantics(
```

to:

```dart
child: MergeSemantics(
```

while keeping the rest of the semantics/focus/gesture tree unchanged.

- [ ] **Step 4: Run the focused button test to verify it passes**

Run: `flutter test test/ui/components/visir_button_test.dart`
Expected: PASS

- [ ] **Step 5: Commit the button layout change**

```bash
git add ui/lib/src/components/visir_button.dart test/ui/components/visir_button_test.dart
git commit -m "feat: make visir button sizing padding driven"
```

### Task 3: Full Verification

**Files:**
- Modify: any touched files from Tasks 1-2 if formatting requires it

- [ ] **Step 1: Format touched files**

Run: `dart format ui/lib/src/theme/visir_component_role_themes.dart ui/lib/src/theme/visir_theme_data.dart ui/lib/src/components/visir_button.dart test/ui/components/visir_button_test.dart`
Expected: Formatter exits successfully.

- [ ] **Step 2: Run analysis**

Run: `dart analyze ui test/ui`
Expected: `No issues found!`

- [ ] **Step 3: Run focused button tests**

Run: `flutter test test/ui/components/visir_button_test.dart`
Expected: PASS

- [ ] **Step 4: Run the full `ui` test suite**

Run: `flutter test test/ui`
Expected: PASS

- [ ] **Step 5: Commit any verification-driven fixes**

```bash
git add ui/lib/src/theme/visir_component_role_themes.dart ui/lib/src/theme/visir_theme_data.dart ui/lib/src/components/visir_button.dart test/ui/components/visir_button_test.dart
git commit -m "chore: finalize visir button vertical padding"
```
