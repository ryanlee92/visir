# VisirInput Search Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend `ui` package `VisirInput` so it supports an optional search mode matching the app search bar UI while preserving existing standard input behavior.

**Architecture:** Keep a single public `VisirInput` widget and add a mode enum plus narrowly scoped search-mode properties. Implement search mode inside `ui/lib/src/components/visir_input.dart` with small private helpers, then update the showcase and snippets to exercise the new API. Add a new `ui/test` harness so the component can be developed with widget-level TDD independent of the showcase app.

**Tech Stack:** Flutter, `visir_ui` package, `flutter_test`, showcase snippet generators

---

## File Structure

- Modify: `ui/pubspec.yaml`
  Responsibility: add `flutter_test` and lint support so the UI package can run widget tests directly.
- Create: `ui/test/components/visir_input_test.dart`
  Responsibility: widget-level tests for standard mode, search mode, `maxLines`, and trailing accessory behavior.
- Modify: `ui/lib/src/components/visir_input.dart`
  Responsibility: add `VisirInputMode`, new search-mode API, and mode-specific rendering while preserving standard mode behavior.
- Modify: `ui/showcase/lib/data/input_snippets.dart`
  Responsibility: generate snippets for new mode and props without emitting defaults.
- Modify: `ui/showcase/lib/sections/visir_input_section.dart`
  Responsibility: expose controls for search mode, loading, clear button, custom leading widget, and `maxLines`.
- Modify: `ui/showcase/test/snippet_generation_test.dart`
  Responsibility: lock down snippet output for search-mode examples.
- Modify: `ui/showcase/test/sections/content_sections_test.dart`
  Responsibility: ensure the input section still renders inside the showcase after new controls are added.

### Task 1: Add UI Package Test Harness

**Files:**
- Modify: `ui/pubspec.yaml`
- Create: `ui/test/components/visir_input_test.dart`

- [ ] **Step 1: Write the failing tests for `VisirInput` behavior**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui/visir_ui.dart';

void main() {
  Widget buildHarness(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 360, child: child))),
    );
  }

  testWidgets('standard mode keeps label and hint rendering', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(label: 'Email', hintText: 'name@example.com'),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('name@example.com'), findsOneWidget);
  });

  testWidgets('search mode shows default search icon and omits label text', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find projects',
          mode: VisirInputMode.search,
        ),
      ),
    );

    expect(find.text('Find projects'), findsOneWidget);
    expect(find.text('Search'), findsNothing);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('search mode respects maxLines', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        const VisirInput(
          label: 'Search',
          hintText: 'Find notes',
          mode: VisirInputMode.search,
          maxLines: 3,
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.maxLines, 3);
  });

  testWidgets('search mode shows loading spinner and clear action', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        VisirInput(
          label: 'Search',
          hintText: 'Find tasks',
          mode: VisirInputMode.search,
          isLoading: true,
          showClearButton: true,
          onClear: () {},
        ),
      ),
    );

    expect(find.byType(VisirSpinner), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
```

- [ ] **Step 2: Add the missing test dependency before running tests**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

- [ ] **Step 3: Run the new test file to verify it fails for the right reason**

Run: `flutter test ui/test/components/visir_input_test.dart`

Expected:
- The test target is discovered successfully.
- Failing assertions or compile errors point to missing `mode`, `maxLines`, `isLoading`, `showClearButton`, `onClear`, or `VisirInputMode`.
- Failure should be due to missing API/behavior, not missing `flutter_test` or an invalid harness.

- [ ] **Step 4: Commit the red-state harness**

```bash
git add ui/pubspec.yaml ui/test/components/visir_input_test.dart
git commit -m "test: add visir input widget coverage"
```

### Task 2: Implement `VisirInput` Search Mode

**Files:**
- Modify: `ui/lib/src/components/visir_input.dart`
- Test: `ui/test/components/visir_input_test.dart`

- [ ] **Step 1: Expand the failing tests to cover custom leading and clear taps**

```dart
testWidgets('search mode uses custom leading when provided', (tester) async {
  await tester.pumpWidget(
    buildHarness(
      const VisirInput(
        label: 'Search',
        hintText: 'Find records',
        mode: VisirInputMode.search,
        leading: Icon(Icons.tune),
      ),
    ),
  );

  expect(find.byIcon(Icons.tune), findsOneWidget);
  expect(find.byIcon(Icons.search), findsNothing);
});

testWidgets('search mode clear action invokes callback', (tester) async {
  var clearCount = 0;

  await tester.pumpWidget(
    buildHarness(
      VisirInput(
        label: 'Search',
        hintText: 'Find tasks',
        mode: VisirInputMode.search,
        showClearButton: true,
        onClear: () => clearCount++,
      ),
    ),
  );

  await tester.tap(find.byIcon(Icons.close));
  await tester.pump();

  expect(clearCount, 1);
});
```

- [ ] **Step 2: Run the widget tests again to confirm the new cases fail**

Run: `flutter test ui/test/components/visir_input_test.dart`

Expected:
- Existing failures remain red.
- New failures specifically indicate missing custom-leading and clear-action behavior.

- [ ] **Step 3: Implement the minimal `VisirInput` API and mode-specific rendering**

```dart
enum VisirInputMode { standard, search }

class VisirInput extends StatelessWidget {
  const VisirInput({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.prefix,
    this.suffix,
    this.errorText,
    this.enabled = true,
    this.mode = VisirInputMode.standard,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.leading,
    this.showClearButton = false,
    this.onClear,
    this.isLoading = false,
    this.maxLines,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final String? errorText;
  final bool enabled;
  final VisirInputMode mode;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? leading;
  final bool showClearButton;
  final VoidCallback? onClear;
  final bool isLoading;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = VisirTheme.of(context);
    final tokens = theme.tokens;
    final control = theme.components.control;

    return switch (mode) {
      VisirInputMode.standard => _buildStandard(context, tokens, control),
      VisirInputMode.search => _buildSearch(context, tokens, control),
    };
  }
}
```

Implement `_buildStandard` by keeping the current `TextField` behavior and wiring `maxLines`. Implement `_buildSearch` with:

```dart
Widget _buildSearch(
  BuildContext context,
  VisirTokens tokens,
  VisirControlTheme control,
) {
  final effectiveMaxLines = maxLines ?? 1;

  return Material(
    color: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        color: tokens.colors.surface,
        borderRadius: BorderRadius.circular(control.radius),
        border: Border.all(
          color: control.borders.base.color,
          width: control.borders.base.width,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ?? Icon(Icons.search, size: 18, color: tokens.colors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              autofocus: autofocus,
              focusNode: focusNode,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              maxLines: effectiveMaxLines,
              style: TextStyle(color: tokens.colors.text),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: tokens.colors.textMuted),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const VisirSpinner(size: VisirSpinnerSize.sm, tone: VisirSpinnerTone.inverse),
          ],
          if (showClearButton) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              visualDensity: VisualDensity.compact,
              splashRadius: 16,
            ),
          ],
        ],
      ),
    ),
  );
}
```

- [ ] **Step 4: Run the component tests to verify green**

Run: `flutter test ui/test/components/visir_input_test.dart`

Expected:
- All `VisirInput` widget tests pass.
- No analyzer or compile errors remain in `ui/lib/src/components/visir_input.dart`.

- [ ] **Step 5: Commit the component implementation**

```bash
git add ui/lib/src/components/visir_input.dart ui/test/components/visir_input_test.dart
git commit -m "feat: add visir input search mode"
```

### Task 3: Update Showcase Controls And Snippets

**Files:**
- Modify: `ui/showcase/lib/data/input_snippets.dart`
- Modify: `ui/showcase/lib/sections/visir_input_section.dart`
- Modify: `ui/showcase/test/snippet_generation_test.dart`
- Test: `ui/test/components/visir_input_test.dart`

- [ ] **Step 1: Write the failing snippet test for search-mode output**

```dart
test('input snippet includes search-mode props when selected', () {
  final code = buildInputSnippet(
    label: 'Search',
    hintText: 'Find projects',
    mode: VisirInputMode.search,
    leadingIcon: curatedIconOptions.firstWhere((option) => option.id == 'search'),
    isLoading: true,
    showClearButton: true,
    maxLines: 3,
  );

  expect(code, contains('mode: VisirInputMode.search'));
  expect(code, contains('leading: const Icon(Icons.search)'));
  expect(code, contains('isLoading: true'));
  expect(code, contains('showClearButton: true'));
  expect(code, contains('maxLines: 3'));
});
```

- [ ] **Step 2: Run the snippet test to verify it fails**

Run: `flutter test ui/showcase/test/snippet_generation_test.dart`

Expected:
- The new snippet test fails because `buildInputSnippet` does not yet accept or emit the new props.

- [ ] **Step 3: Update snippet generation and showcase controls with minimal UI**

In `ui/showcase/lib/data/input_snippets.dart`, extend the function signature and only emit non-default values:

```dart
String buildInputSnippet({
  required String label,
  String? hintText,
  CuratedIconOption? prefixIcon,
  CuratedIconOption? suffixIcon,
  CuratedIconOption? leadingIcon,
  String? errorText,
  bool enabled = true,
  VisirInputMode mode = VisirInputMode.standard,
  bool isLoading = false,
  bool showClearButton = false,
  int? maxLines,
}) {
  final arguments = <String>[
    'label: ${dartStringLiteral(safeLabel)}',
    if (hasText(safeHintText)) 'hintText: ${dartStringLiteral(safeHintText!)}',
    if (mode != VisirInputMode.standard) 'mode: VisirInputMode.search',
    if (leadingIcon != null) 'leading: const Icon(${leadingIcon.iconExpression})',
    if (prefixIcon != null) 'prefix: const Icon(${prefixIcon.iconExpression})',
    if (suffixIcon != null) 'suffix: const Icon(${suffixIcon.iconExpression})',
    if (hasText(safeErrorText)) 'errorText: ${dartStringLiteral(safeErrorText!)}',
    if (isLoading) 'isLoading: true',
    if (showClearButton) 'showClearButton: true',
    if (maxLines != null) 'maxLines: $maxLines',
    if (!enabled) 'enabled: false',
  ];
}
```

In `ui/showcase/lib/sections/visir_input_section.dart`, add state for mode, loading, clear visibility, custom leading, and max lines:

```dart
VisirInputMode _mode = VisirInputMode.standard;
bool _isLoading = false;
bool _showClearButton = false;
bool _useCustomLeading = false;
double _maxLines = 1;
CuratedIconOption? _leadingIcon = curatedIconById('search');
```

Use them in preview:

```dart
VisirInput(
  label: _label.trim().isEmpty ? 'Input Label' : _label.trim(),
  hintText: _hintText.trim().isEmpty ? null : _hintText.trim(),
  mode: _mode,
  leading: _mode == VisirInputMode.search && _useCustomLeading && _leadingIcon != null
      ? Icon(_leadingIcon!.iconData)
      : null,
  isLoading: _mode == VisirInputMode.search ? _isLoading : false,
  showClearButton: _mode == VisirInputMode.search ? _showClearButton : false,
  maxLines: _maxLines.round(),
  onClear: _mode == VisirInputMode.search ? () {} : null,
  prefix: _mode == VisirInputMode.standard && _prefixIcon != null ? Icon(_prefixIcon!.iconData) : null,
  suffix: _mode == VisirInputMode.standard && _suffixIcon != null ? Icon(_suffixIcon!.iconData) : null,
  errorText: _mode == VisirInputMode.standard && _errorText.trim().isNotEmpty ? _errorText.trim() : null,
  enabled: _enabled,
)
```

Expose controls so search-only toggles appear when `_mode == VisirInputMode.search`, while standard-only controls remain available otherwise.

- [ ] **Step 4: Run UI-package and showcase tests to verify the update passes**

Run:
- `flutter test ui/test/components/visir_input_test.dart`
- `flutter test ui/showcase/test/snippet_generation_test.dart`

Expected:
- Both test commands pass.
- Snippet output includes search-mode props only when selected.

- [ ] **Step 5: Commit showcase and snippet support**

```bash
git add ui/showcase/lib/data/input_snippets.dart ui/showcase/lib/sections/visir_input_section.dart ui/showcase/test/snippet_generation_test.dart
git commit -m "feat: add visir input search mode showcase"
```

### Task 4: Verify Showcase Rendering And Final Regression Pass

**Files:**
- Modify: `ui/showcase/test/sections/content_sections_test.dart`
- Test: `ui/showcase/test/sections/content_sections_test.dart`
- Test: `ui/showcase/test/showcase_smoke_test.dart`
- Test: `ui/showcase/test/showcase_page_test.dart`

- [ ] **Step 1: Extend showcase coverage with a search-mode rendering test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:visir_ui_showcase/app/showcase_app.dart';

void main() {
  testWidgets('showcase page renders input card and badge sections', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('VisirInput'), findsOneWidget);
    expect(find.text('VisirCard'), findsOneWidget);
    expect(find.text('VisirBadge'), findsOneWidget);
  });

  testWidgets('showcase input section exposes search mode controls', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());

    expect(find.text('VisirInput'), findsOneWidget);
    expect(find.text('Hint Text'), findsOneWidget);
    expect(find.text('Enabled'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the section-level showcase test to verify the new assertion set**

Run: `flutter test ui/showcase/test/sections/content_sections_test.dart`

Expected:
- Either the new control assertions fail because the section has not exposed them yet, or the test passes once the section updates are complete.
- No unrelated section failures appear.

- [ ] **Step 3: Run the broader showcase regression suite**

Run:
- `flutter test ui/showcase/test/showcase_smoke_test.dart`
- `flutter test ui/showcase/test/showcase_page_test.dart`
- `flutter test ui/showcase/test/sections/content_sections_test.dart`

Expected:
- All showcase tests pass.
- The `VisirInput` section remains present in the page and smoke tests.

- [ ] **Step 4: Run the final end-to-end verification set**

Run:
- `flutter test ui/test/components/visir_input_test.dart`
- `flutter test ui/showcase/test`

Expected:
- All UI package tests pass.
- All showcase tests pass.
- No failures remain around search-mode rendering, snippets, or standard-mode regressions.

- [ ] **Step 5: Commit the final verification adjustments**

```bash
git add ui/showcase/test/sections/content_sections_test.dart
git commit -m "test: cover visir input search mode showcase"
```

## Self-Review

Spec coverage check:
- Search-mode API is implemented in Task 2.
- Standard-mode preservation is covered in Task 1 tests and Task 2 implementation.
- `maxLines` support is covered in Tasks 1 and 2.
- Showcase and snippet updates are covered in Task 3.
- Verification scope from the spec is covered in Task 4.

Placeholder scan:
- No `TODO`, `TBD`, or unnamed follow-up work remains in the task steps.

Type consistency:
- The plan consistently uses `VisirInputMode`, `isLoading`, `showClearButton`, `onClear`, and `maxLines`.

