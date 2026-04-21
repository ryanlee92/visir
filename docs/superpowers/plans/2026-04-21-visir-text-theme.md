# Visir Text Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a shared `VisirTextThemeData` to the UI theme layer and move `Visir*` components plus the showcase typography onto that shared text system.

**Architecture:** Introduce one immutable text theme object on `VisirThemeData` and treat it as the source of truth for component typography. Core widgets should read text styles from `VisirTheme.of(context).text` instead of `Theme.of(context).textTheme`, while the showcase app mirrors those styles into Material `ThemeData.textTheme` for any remaining Material widgets.

**Tech Stack:** Flutter, Dart, `flutter_test`, `visir_ui`, showcase app widgets

---

## File Structure

- Create: `ui/lib/src/theme/visir_text_theme.dart`
  Responsibility: immutable text style palette with `copyWith`, equality, and fallback defaults for hero, title, body, label, and caption roles.
- Modify: `ui/lib/src/theme/visir_theme_data.dart`
  Responsibility: add the `text` theme to `VisirThemeData`, thread it through `fallback()` and `copyWith()`, and keep existing component-role defaults intact.
- Modify: `ui/lib/visir_ui.dart`
  Responsibility: export the new text theme class.
- Modify: `ui/lib/src/components/visir_section.dart`
  Responsibility: use the shared title style for the section heading.
- Modify: `ui/lib/src/components/visir_badge.dart`
  Responsibility: use the shared label style for badge text.
- Modify: `ui/lib/src/components/visir_empty_state.dart`
  Responsibility: use the shared title/body styles for empty state copy.
- Modify: `ui/lib/src/components/visir_button.dart`
  Responsibility: use the shared label style for the button label.
- Modify: `ui/lib/src/components/visir_input.dart`
  Responsibility: use the shared label/body/caption styles for input label, hint, and error text.
- Modify: `ui/lib/src/components/visir_app_bar.dart`
  Responsibility: use the shared title style for the app-bar title.
- Modify: `ui/showcase/lib/app/showcase_theme.dart`
  Responsibility: build Material `ThemeData.textTheme` from `VisirThemeData.text` so showcase-only Material widgets stay consistent.
- Modify: `ui/showcase/lib/app/showcase_app.dart`
  Responsibility: provide light/dark `VisirTextThemeData` overrides alongside the existing light/dark color overrides.
- Modify: `ui/showcase/lib/app/showcase_page.dart`
  Responsibility: use the shared hero/body/caption styles for the page intro and footer copy.
- Modify: `ui/showcase/lib/sections/*.dart`
  Responsibility: replace section-local `Theme.of(context).textTheme` lookups with `VisirTheme.of(context).text` for headings, descriptions, labels, and helper text.
- Create: `test/ui/theme/visir_text_theme_test.dart`
  Responsibility: direct unit coverage for fallback values, `copyWith`, and equality of the new theme object.
- Modify: `test/ui/theme/visir_theme_test.dart`
  Responsibility: verify `VisirTheme.of` exposes the new text theme and that custom overrides flow through.
- Modify: `test/ui/components/visir_supporting_components_test.dart`
  Responsibility: lock `VisirSection`, `VisirBadge`, and `VisirEmptyState` styling against the new text theme.
- Modify: `ui/test/components/visir_input_test.dart`
  Responsibility: verify input label/error text pulls from the shared text theme.
- Modify: `ui/test/components/visir_app_bar_test.dart`
  Responsibility: verify the app-bar title style comes from the shared text theme.
- Modify: `test/ui/components/visir_button_test.dart`
  Responsibility: verify button labels still render with the intended shared text style.
- Modify: `ui/showcase/test/showcase_page_test.dart`
  Responsibility: verify showcase hero/body text uses the shared text theme and the light/dark page still renders correctly.

### Task 1: Add `VisirTextThemeData` to the theme layer

**Files:**
- Create: `ui/lib/src/theme/visir_text_theme.dart`
- Modify: `ui/lib/src/theme/visir_theme_data.dart`
- Modify: `ui/lib/visir_ui.dart`
- Create: `test/ui/theme/visir_text_theme_test.dart`
- Modify: `test/ui/theme/visir_theme_test.dart`

- [ ] **Step 1: Write the failing tests for the text theme object and `VisirThemeData` plumbing**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../ui/visir_ui.dart';

void main() {
  test('VisirTextThemeData copyWith preserves unchanged styles', () {
    final fallback = VisirThemeData.fallback();
    final updated = fallback.text.copyWith(
      title: fallback.text.title.copyWith(fontSize: 29),
    );

    expect(updated.title.fontSize, 29);
    expect(updated.body, fallback.text.body);
    expect(updated.label, fallback.text.label);
  });

  test('VisirThemeData fallback exposes the text theme', () {
    final fallback = VisirThemeData.fallback();

    expect(fallback.text.title.fontSize, greaterThan(fallback.text.body.fontSize));
    expect(fallback.text.caption.fontSize, lessThan(fallback.text.body.fontSize));
  });
}
```

- [ ] **Step 2: Run the new theme tests to verify they fail for missing API**

Run: `flutter test test/ui/theme/visir_text_theme_test.dart test/ui/theme/visir_theme_test.dart`

Expected:
- The test target is discovered successfully.
- Failures point to missing `VisirTextThemeData`, missing `VisirThemeData.text`, or missing `copyWith` plumbing.

- [ ] **Step 3: Implement the new theme class and thread it through `VisirThemeData`**

```dart
@immutable
class VisirTextThemeData {
  const VisirTextThemeData({
    required this.hero,
    required this.title,
    required this.body,
    required this.label,
    required this.caption,
  });

  final TextStyle hero;
  final TextStyle title;
  final TextStyle body;
  final TextStyle label;
  final TextStyle caption;

  VisirTextThemeData copyWith({
    TextStyle? hero,
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return VisirTextThemeData(
      hero: hero ?? this.hero,
      title: title ?? this.title,
      body: body ?? this.body,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }
}
```

Update `VisirThemeData` so `fallback()` creates a text palette from the current token colors, `copyWith()` accepts `text:`, and the `text` field participates in equality and hash code.

- [ ] **Step 4: Run the theme tests again and confirm the new object is wired**

Run: `flutter test test/ui/theme/visir_text_theme_test.dart test/ui/theme/visir_theme_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the theme-layer change**

```bash
git add ui/lib/src/theme/visir_text_theme.dart ui/lib/src/theme/visir_theme_data.dart ui/lib/visir_ui.dart test/ui/theme/visir_text_theme_test.dart test/ui/theme/visir_theme_test.dart
git commit -m "feat: add shared visir text theme"
```

### Task 2: Migrate core `Visir*` components onto the shared text styles

**Files:**
- Modify: `ui/lib/src/components/visir_section.dart`
- Modify: `ui/lib/src/components/visir_badge.dart`
- Modify: `ui/lib/src/components/visir_empty_state.dart`
- Modify: `ui/lib/src/components/visir_button.dart`
- Modify: `ui/lib/src/components/visir_input.dart`
- Modify: `ui/lib/src/components/visir_app_bar.dart`
- Modify: `test/ui/components/visir_supporting_components_test.dart`
- Modify: `test/ui/components/visir_button_test.dart`
- Modify: `ui/test/components/visir_input_test.dart`
- Modify: `ui/test/components/visir_app_bar_test.dart`

- [ ] **Step 1: Write component assertions against `VisirTheme.of(context).text`**

```dart
final theme = VisirTheme.of(context).text;

expect(find.text('Section title'), findsOneWidget);
expect(tester.widget<Text>(find.text('Section title')).style, theme.title);
expect(tester.widget<Text>(find.text('Badge')).style, theme.label);
expect(tester.widget<Text>(find.text('Error text')).style, theme.caption);
```

Also add a `VisirSection` assertion that its title style is visually larger than its body copy when both are driven by the shared text theme.

- [ ] **Step 2: Run the component tests to verify the current hardcoded `TextStyle`s fail the new expectations**

Run: `flutter test test/ui/components/visir_supporting_components_test.dart test/ui/components/visir_button_test.dart ui/test/components/visir_input_test.dart ui/test/components/visir_app_bar_test.dart`

Expected:
- The tests discover successfully.
- Failures point to direct `TextStyle` calls in the component files.

- [ ] **Step 3: Replace local typography with the shared text palette**

Use the shared text theme directly in each component:

```dart
final text = VisirTheme.of(context).text;

Text(title!, style: text.title);
Text(label, style: text.label);
Text(description, style: text.body);
Text(errorText!, style: text.caption);
```

Keep only local color overrides where the component still needs token-specific color treatment.

- [ ] **Step 4: Re-run the component tests and confirm the shared typography is applied**

Run: `flutter test test/ui/components/visir_supporting_components_test.dart test/ui/components/visir_button_test.dart ui/test/components/visir_input_test.dart ui/test/components/visir_app_bar_test.dart`

Expected: PASS.

- [ ] **Step 5: Commit the core component migration**

```bash
git add ui/lib/src/components/visir_section.dart ui/lib/src/components/visir_badge.dart ui/lib/src/components/visir_empty_state.dart ui/lib/src/components/visir_button.dart ui/lib/src/components/visir_input.dart ui/lib/src/components/visir_app_bar.dart test/ui/components/visir_supporting_components_test.dart test/ui/components/visir_button_test.dart ui/test/components/visir_input_test.dart ui/test/components/visir_app_bar_test.dart
git commit -m "feat: move visir components onto shared text theme"
```

### Task 3: Update the showcase to consume the new text theme

**Files:**
- Modify: `ui/showcase/lib/app/showcase_app.dart`
- Modify: `ui/showcase/lib/app/showcase_theme.dart`
- Modify: `ui/showcase/lib/app/showcase_page.dart`
- Modify: `ui/showcase/lib/sections/visir_badge_section.dart`
- Modify: `ui/showcase/lib/sections/visir_button_section.dart`
- Modify: `ui/showcase/lib/sections/visir_card_section.dart`
- Modify: `ui/showcase/lib/sections/visir_divider_section.dart`
- Modify: `ui/showcase/lib/sections/visir_empty_state_section.dart`
- Modify: `ui/showcase/lib/sections/visir_icon_button_section.dart`
- Modify: `ui/showcase/lib/sections/visir_input_section.dart`
- Modify: `ui/showcase/lib/sections/visir_section_section.dart`
- Modify: `ui/showcase/lib/sections/visir_spinner_section.dart`
- Modify: `ui/showcase/test/showcase_page_test.dart`
- Modify: `ui/showcase/test/sections/content_sections_test.dart`
- Modify: `ui/showcase/test/sections/supporting_sections_test.dart`

- [ ] **Step 1: Write showcase assertions that the hero and section text are driven by the shared text palette**

```dart
final text = VisirTheme.of(tester.element(find.byKey(showcaseScrollViewKey))).text;

expect(tester.widget<Text>(find.text('Interactive component showcase for the visir_ui package.')).style, text.hero);
expect(tester.widget<Text>(find.text('VisirSection')).style, text.title);
expect(tester.widget<Text>(find.text('Built for internal component exploration and API discovery.')).style, text.caption);
```

- [ ] **Step 2: Run the showcase tests to confirm the current `Theme.of(context).textTheme` usage fails**

Run: `flutter test ui/showcase/test/showcase_page_test.dart ui/showcase/test/sections/content_sections_test.dart ui/showcase/test/sections/supporting_sections_test.dart`

Expected:
- The tests discover successfully.
- Failures point to showcase files still relying on Material typography directly.

- [ ] **Step 3: Build the Material theme text styles from `VisirThemeData.text` and migrate showcase section copy**

In `ui/showcase/lib/app/showcase_theme.dart`, map the shared text palette into `ThemeData.textTheme` for Material widgets that still need it:

```dart
final visirText = visirThemeData.text;
return base.copyWith(
  textTheme: base.textTheme.copyWith(
    displayLarge: visirText.hero,
    headlineSmall: visirText.title,
    titleLarge: visirText.title,
    titleMedium: visirText.title,
    bodyLarge: visirText.body,
    bodyMedium: visirText.body,
    labelLarge: visirText.label,
    labelMedium: visirText.label,
    bodySmall: visirText.caption,
  ),
);
```

In `ui/showcase/lib/app/showcase_app.dart`, provide light/dark `VisirTextThemeData` overrides alongside the existing light/dark color overrides so the page stays legible in both modes.

In the section files and `showcase_page.dart`, read typography from `VisirTheme.of(context).text` instead of `Theme.of(context).textTheme`.

- [ ] **Step 4: Re-run the showcase suite and confirm the typography still renders with light/dark mode**

Run: `flutter test`

Expected: PASS.

- [ ] **Step 5: Commit the showcase migration**

```bash
git add ui/showcase/lib/app/showcase_app.dart ui/showcase/lib/app/showcase_theme.dart ui/showcase/lib/app/showcase_page.dart ui/showcase/lib/sections/visir_badge_section.dart ui/showcase/lib/sections/visir_button_section.dart ui/showcase/lib/sections/visir_card_section.dart ui/showcase/lib/sections/visir_divider_section.dart ui/showcase/lib/sections/visir_empty_state_section.dart ui/showcase/lib/sections/visir_icon_button_section.dart ui/showcase/lib/sections/visir_input_section.dart ui/showcase/lib/sections/visir_section_section.dart ui/showcase/lib/sections/visir_spinner_section.dart ui/showcase/test/showcase_page_test.dart ui/showcase/test/sections/content_sections_test.dart ui/showcase/test/sections/supporting_sections_test.dart
git commit -m "feat: apply shared text theme to showcase"
```

### Task 4: Final verification

**Files:**
- Modify: only the files changed by Tasks 1-3 if any final test-driven cleanup is needed.

- [ ] **Step 1: Run the full UI package suite**

Run: `flutter test` in `ui/`

Expected: PASS.

- [ ] **Step 2: Run the full showcase suite**

Run: `flutter test` in `ui/showcase/`

Expected: PASS.

- [ ] **Step 3: Sanity-check the text theme API surface**

Confirm the following compile and are exported from `package:visir_ui/visir_ui.dart`:

```dart
final text = VisirTheme.of(context).text;
Text('Title', style: text.title);
Text('Body', style: text.body);
Text('Label', style: text.label);
Text('Error', style: text.caption);
```

- [ ] **Step 4: Commit the finished branch state**

```bash
git add .
git commit -m "feat: add shared visir text theme"
```
