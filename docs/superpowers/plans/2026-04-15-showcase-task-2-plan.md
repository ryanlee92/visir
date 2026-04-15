I'm using the writing-plans skill to create the implementation plan.

# Showcase Task 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the deprecated surface and opacity APIs in the showcase while tightening the smoke test scroll assertions so the playground loads reliably on every platform.

**Architecture:** Keep the existing single `ShowcaseTheme` entry point and `ShowcasePage` layout but remap the vanilla beige surface tones into the newer `surfaceContainer*` slots. Update the smoke test so it inspects the `ScrollableState` instead of fragile layout coordinates, which keeps the test deterministic across layout tweaks.

**Tech Stack:** Flutter (Material 3), Dart, flutter_test.

---

### Task 1: Adjust showcase theme colors

**Files:**
- Modify: `ui/showcase/lib/app/showcase_theme.dart:6-24`

- [ ] **Step 1: Update the `ColorScheme.light` instantiation**

```dart
final base = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFF6F0E8),
    onSurface: Color(0xFF17161A),
  ),
);
```

- [ ] **Step 2: Keep the scaffold background and text theme aligned with onSurface**

```dart
return base.copyWith(
  scaffoldBackgroundColor: base.colorScheme.surface,
  textTheme: base.textTheme.apply(
    bodyColor: base.colorScheme.onSurface,
    displayColor: base.colorScheme.onSurface,
  ),
);
```

### Task 2: Map page sections to surface containers and update opacity

**Files:**
- Modify: `ui/showcase/lib/app/showcase_page.dart:28-65`

- [ ] **Step 1: Replace `colors.surfaceVariant` with `colors.surfaceContainerHigh`**

```dart
decoration: BoxDecoration(
  color: colors.surfaceContainerHigh,
  borderRadius: BorderRadius.circular(12),
),
```

- [ ] **Step 2: Switch the overlay color to `withValues(alpha: 0.6)`**

```dart
decoration: BoxDecoration(
  color: Colors.white.withValues(alpha: 0.6),
  borderRadius: BorderRadius.circular(8),
),
```

### Task 3: Harden the smoke test scroll assertions

**Files:**
- Modify: `ui/showcase/test/showcase_smoke_test.dart:13-50`

- [ ] **Step 1: Scope the `Scrollable` finder to the `SingleChildScrollView`**

```dart
final scrollable = find.descendant(
  of: find.byType(SingleChildScrollView),
  matching: find.byType(Scrollable),
);
final scrollState = tester.state<ScrollableState>(scrollable);
expect(scrollState.position.pixels, equals(0));
```

- [ ] **Step 2: Drag the scrollable and capture the increased offset**

```dart
await tester.drag(scrollable, const Offset(0, -150));
await tester.pumpAndSettle();
final afterDragOffset = scrollState.position.pixels;
expect(afterDragOffset, greaterThan(0));
```

- [ ] **Step 3: Tap the “Jump to button” link and verify the offset drops**

```dart
await tester.tap(find.text('Jump to ${prettySectionTitle('button')}'));
await tester.pumpAndSettle();
final postJumpOffset = scrollState.position.pixels;
expect(postJumpOffset, lessThan(afterDragOffset));
```

### Task 4: Verification sweep

**Files:**
- Test: `ui/showcase`

- [ ] **Step 1: Run Dart analyzer**

```bash
cd ui/showcase && dart analyze lib test
```
Expected: `All analyzed files should pass without issues.`

- [ ] **Step 2: Run the focused smoke test**

```bash
cd ui/showcase && flutter test test/showcase_smoke_test.dart
```
Expected: `1 test, passing`

- [ ] **Step 3: Produce a release web build**

```bash
cd ui/showcase && flutter build web --release
```
Expected: `Build completes without errors.`
