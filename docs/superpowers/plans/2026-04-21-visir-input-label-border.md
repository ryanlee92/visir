# VisirInput Label and Border Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `VisirInput` support an optional label and a token-driven border mode with `none` as the default, while preserving automatic error-border behavior.

**Architecture:** `VisirInput` keeps one shell-based layout: the outer container owns spacing, radius, and border tokens, and the inner `TextField` stays visually raw. The label becomes optional presentation above the shell, and border state becomes an explicit enum that resolves through `VisirTheme` tokens, with `errorText` forcing the error border.

**Tech Stack:** Flutter, widget tests, `visir_ui`, `visir_ui_showcase`

---

### Task 1: Update `VisirInput` API and widget contracts

**Files:**
- Modify: `ui/lib/src/components/visir_input.dart`
- Modify: `ui/test/components/visir_input_test.dart`

- [ ] **Step 1: Write the failing tests**

Add tests that exercise the new contract directly:

```dart
testWidgets('input can omit label entirely', (tester) async {
  await tester.pumpWidget(
    buildHarness(
      const VisirInput(hintText: 'name@example.com'),
    ),
  );

  expect(find.text('name@example.com'), findsOneWidget);
  expect(find.text('Email'), findsNothing);
});

testWidgets('input border defaults to none and can opt into semantic tokens', (tester) async {
  expect(
    (tester.widget<Container>(find.byKey(const ValueKey('visir-input-shell')))
            .decoration as BoxDecoration)
        .border,
    isNull,
  );
});

testWidgets('errorText forces the error border', (tester) async {
  await tester.pumpWidget(
    buildHarness(
      const VisirInput(
        hintText: 'name@example.com',
        border: VisirInputBorder.success,
        errorText: 'Invalid email',
      ),
    ),
  );

  final shell = tester.widget<Container>(
    find.byKey(const ValueKey('visir-input-shell')),
  );
  final decoration = shell.decoration as BoxDecoration;
  final border = decoration.border! as Border;

  expect(border.top.color, VisirTheme.of(tester.element(find.byType(VisirInput))).tokens.colors.danger);
});
```

- [ ] **Step 2: Run the focused test file and confirm the new expectations fail**

Run: `flutter test test/components/visir_input_test.dart`
Expected: fail because `VisirInput` still requires the label and does not expose a token-driven border prop.

- [ ] **Step 3: Implement the minimal API and layout changes**

Update `VisirInput` so the constructor and render path become:

```dart
enum VisirInputBorder { none, base, success, error }

class VisirInput extends StatelessWidget {
  const VisirInput({
    super.key,
    this.label,
    this.border = VisirInputBorder.none,
    this.hintText,
    this.controller,
    this.suffix,
    this.suffixTooltip,
    this.suffixOnPressed,
    this.errorText,
    this.enabled = true,
    this.onSubmitted,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.leading,
    this.leadingTooltip,
    this.leadingOnPressed,
    this.showClearButton = false,
    this.onClear,
    this.isLoading = false,
    this.maxLines,
  });
}
```

Then:
- render the label only when `label != null && label!.trim().isNotEmpty`
- resolve the shell border from `border`, except when `errorText` is present, which must force the danger token
- keep the inner `TextField` decoration collapsed and unframed
- keep the shell padding, radius, leading/trailing buttons, spinner, and clear action unchanged

- [ ] **Step 4: Run the widget tests and confirm they pass**

Run: `flutter test test/components/visir_input_test.dart`
Expected: PASS

- [ ] **Step 5: Commit the core widget change**

```bash
git add ui/lib/src/components/visir_input.dart ui/test/components/visir_input_test.dart
git commit -m "feat: make visir input label optional and border token-driven"
```

### Task 2: Update the showcase input section and snippet generation

**Files:**
- Modify: `ui/showcase/lib/sections/visir_input_section.dart`
- Modify: `ui/showcase/lib/data/input_snippets.dart`
- Modify: `ui/showcase/test/sections/content_sections_test.dart`
- Modify: `ui/showcase/test/snippet_generation_test.dart`

- [ ] **Step 1: Write the failing showcase tests**

Add coverage that the showcase can demonstrate the new input contract:

```dart
testWidgets('input section can hide the label and show border states', (tester) async {
  await tester.pumpWidget(const ShowcaseApp());

  expect(find.text('Label'), findsOneWidget);
  expect(find.text('Border'), findsOneWidget);
  expect(find.text('Input Label'), findsOneWidget);
});

test('input snippet omits label when the showcase label is empty', () {
  expect(
    buildInputSnippet(
      label: '',
      hintText: 'name@example.com',
      border: VisirInputBorder.none,
    ),
    contains('hintText:'),
  );
  expect(
    buildInputSnippet(
      label: '',
      hintText: 'name@example.com',
      border: VisirInputBorder.none,
    ),
    isNot(contains('label:')),
  );
});
```

- [ ] **Step 2: Run the showcase tests and confirm they fail**

Run: `flutter test test/sections/content_sections_test.dart test/snippet_generation_test.dart`
Expected: fail because the showcase still assumes `label` is always required and the snippet helper does not know about `VisirInputBorder`.

- [ ] **Step 3: Update the showcase controls and snippet builder**

Change the section preview to:
- allow the label field to be empty
- add a border-state selector for `none/base/success/error`
- keep `errorText` as a separate control and let it force the error border in the preview

Update the snippet helper to accept:

```dart
String buildInputSnippet({
  String? label,
  String? hintText,
  CuratedIconOption? suffixIcon,
  CuratedIconOption? leadingIcon,
  String? errorText,
  VisirInputBorder border = VisirInputBorder.none,
  bool enabled = true,
  bool isLoading = false,
  bool showClearButton = false,
  int? maxLines,
})
```

Then emit `label:` only when non-empty, and include `border: VisirInputBorder.<name>` whenever the border is not `none`.

- [ ] **Step 4: Run the showcase tests and confirm they pass**

Run: `flutter test test/sections/content_sections_test.dart test/snippet_generation_test.dart`
Expected: PASS

- [ ] **Step 5: Commit the showcase update**

```bash
git add ui/showcase/lib/sections/visir_input_section.dart ui/showcase/lib/data/input_snippets.dart ui/showcase/test/sections/content_sections_test.dart ui/showcase/test/snippet_generation_test.dart
git commit -m "feat: update visir input showcase for optional label and border states"
```

### Task 3: Final verification

**Files:**
- Verify: `ui/lib/src/components/visir_input.dart`
- Verify: `ui/showcase/lib/sections/visir_input_section.dart`
- Verify: `ui/showcase/lib/data/input_snippets.dart`
- Verify: `ui/test/components/visir_input_test.dart`
- Verify: `ui/showcase/test/sections/content_sections_test.dart`
- Verify: `ui/showcase/test/snippet_generation_test.dart`

- [ ] **Step 1: Run the full `ui` suite**

Run: `flutter test` in `ui`
Expected: PASS

- [ ] **Step 2: Run the full showcase suite**

Run: `flutter test` in `ui/showcase`
Expected: PASS

- [ ] **Step 3: Review the final diff**

Run: `git diff --stat`
Expected: only the files listed above changed, with no unrelated edits.
