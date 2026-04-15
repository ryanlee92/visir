# Visir UI

Repo-local Flutter UI library living at top-level `ui/`.

## Why this exists

This library provides clean, enum-driven `Visir` components without coupling to existing app widget internals.

## Import note

Because this library intentionally lives outside `lib/`, consume it with relative imports inside this repository for now.
The number of `../` segments depends on where the importing file lives.

Examples:

- From `lib/features/inbox/view/inbox_panel.dart`:
  `import '../../../../ui/visir_ui.dart';`
- From `test/ui/test_ui_widget.dart`:
  `import '../../ui/visir_ui.dart';`

```dart
import '../../ui/visir_ui.dart';
```

## Components

- `VisirButton`
- `VisirIconButton`
- `VisirInput`
- `VisirCard`
- `VisirBadge`
- `VisirSection`
- `VisirDivider`
- `VisirSpinner`
- `VisirEmptyState`

## Theme and Foundations

`visir_ui.dart` also exports the theme and foundation surface, not only widgets.
Use `VisirTheme` / `VisirThemeData` to read configured styling, and use enums/tokens
(`Visir*Variant`, `Visir*Size`, spacing/radius/motion/color tokens) for consistent,
enum-driven API usage across components.

## Example

```dart
import 'package:flutter/material.dart';

import '../../ui/visir_ui.dart';

class ExamplePanel extends StatelessWidget {
  const ExamplePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return VisirSection(
      title: 'Workspace',
      child: VisirCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VisirBadge(label: 'Beta', tone: VisirBadgeTone.primary),
            const SizedBox(height: 12),
            const VisirInput(label: 'Name', hintText: 'Roadmap review'),
            const SizedBox(height: 12),
            VisirButton(
              label: 'Continue',
              variant: VisirButtonVariant.primary,
              size: VisirButtonSize.md,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```
