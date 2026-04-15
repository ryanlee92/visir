# Visir UI

Repo-local Flutter UI library living at top-level `ui/`.

## Why this exists

This library provides clean, enum-driven `Visir` components without coupling to existing app widget internals.

## Import note

Because this library intentionally lives outside `lib/`, consume it with relative imports inside this repository for now.

```dart
import '../../ui/visir_ui.dart';
```
