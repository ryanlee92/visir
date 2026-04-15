# Showcase Task 2 follow-up fix

## Context
- The showcase worktree is currently at HEAD `b60e8ed`, and Task 2 requested replacing deprecated Material APIs plus hardening the smoke test that validates scrolling and jumping between sections.
- The affected files are `showcase_page.dart`, `showcase_theme.dart`, and `showcase_smoke_test.dart` under `ui/showcase`.

## Requirements
1. Swap the deprecated `colors.surfaceVariant` usage for the most appropriate `surfaceContainer*` color slot so that sections keep their muted background without referencing removed APIs.
2. Replace every `withOpacity` call in this module with `withValues(alpha: value)` (preserving the same alpha value) because `withOpacity` is deprecated on `Color`.
3. Update `showcase_theme.dart` to avoid `ColorScheme.background`/`onBackground`, favoring `surface`/`onSurface` and keeping the scaffold/background color alignment correct.
4. Make the smoke test less brittle: scope the `Scrollable` finder explicitly and assert behavior through scroll position rather than fragile top-left deltas.

## Approach

### Colors & theme
- Keep the pale `0xFFF6F0E8` tone, mapping it into `colorScheme.surface`/`onSurface` and also plugging it into `scaffoldBackgroundColor`. We are assuming the TonalPalette should not change unless directed otherwise.
- For the per-section container, use `colorScheme.surfaceContainerHigh` (the closest elevated surface slot) instead of `surfaceVariant`.
- Always call `withValues(alpha: value)` (the same alpha we previously supplied to `withOpacity`) when deriving a translucent white overlay.

### Smoke test
- Target the `Scrollable` that lives inside the `SingleChildScrollView` so we cannot accidentally exercise an unrelated scrollable.
- Read the `ScrollableState.position.pixels` to confirm scroll offset changes: it should start at `0`, rise after dragging, and drop after tapping the jump button. This avoids depending on exact coordinates which drift with layout tweaks.
- Keep the existing assertions about hero text, jump buttons and placeholder count unchanged.

### Testing
- `cd ui/showcase && dart analyze lib test`
- `cd ui/showcase && flutter test test/showcase_smoke_test.dart`
- `cd ui/showcase && flutter build web --release`

## Assumptions
- Since there has been no additional instruction, the showcase should keep the existing background tone (`0xFFF6F0E8`) across both the `surface` and the highlighted container.
