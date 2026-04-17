# VisirInput Search Mode Design

## Summary

Extend `VisirInput` in the `ui` package so it remains a general-purpose input component while supporting an optional search-style mode that matches the UI of the app-level `VisirSearchBar`.

The goal is visual and behavioral alignment at the component level without importing app-layer widgets or embedding async search workflow state into the reusable UI package.

## Current State

`ui/lib/src/components/visir_input.dart` currently provides a labeled form input with:

- Required `label`
- Optional `hintText`
- Optional `controller`
- Optional `prefix` and `suffix`
- Optional `errorText`
- `enabled`

It uses themed borders, fill color, and floating label styling.

`lib/features/common/presentation/widgets/visir_search_bar.dart` currently provides search-specific UI with:

- Leading search icon
- Dense single-line input chrome
- Optional loading indicator
- Optional close action
- Search submission and change callbacks
- Focus and autofill-related props

The two components are visually inconsistent and live in different layers.

## Goals

- Keep `VisirInput` reusable as a general-purpose input.
- Add an optional search mode that matches the app search bar UI.
- Preserve the existing standard input behavior for current consumers.
- Support caller-controlled multiline behavior via `maxLines`.
- Keep search-specific async state outside the component.
- Keep the `ui` package free of dependencies on app-only widgets and extensions.

## Non-Goals

- Refactor app-layer search logic into the `ui` package.
- Make `VisirInput` responsible for async loading state transitions.
- Force all consumers onto the search presentation.
- Require the app search bar to be rewritten in the same change.

## Proposed API

Add a public mode enum:

```dart
enum VisirInputMode { standard, search }
```

Extend `VisirInput` with:

- `mode`
- `onSubmitted`
- `onChanged`
- `autofocus`
- `focusNode`
- `leading`
- `showClearButton`
- `onClear`
- `isLoading`
- `maxLines`

### API Rules

- `mode` defaults to `VisirInputMode.standard`.
- Existing props remain valid and preserve current behavior in standard mode.
- Search-specific props are only meaningful in search mode.
- `maxLines` is supported in both modes.
- In search mode, `maxLines` defaults to `1` if omitted.

## Behavior Design

### Standard Mode

Standard mode remains the current labeled form input:

- Use `TextField`
- Keep floating label behavior
- Keep existing themed borders and fill
- Keep `prefix`, `suffix`, `hintText`, `errorText`, and `enabled`
- Respect `maxLines` if provided

This path should be visually unchanged except for any additions needed to support shared internal code.

### Search Mode

Search mode uses search-bar chrome while remaining a general-purpose field:

- Dense input layout
- Search icon on the left by default
- Allow `leading` to override the default left icon/widget
- Use `hintText` as the primary prompt
- Do not show the floating label presentation
- Show a trailing loading indicator when `isLoading == true`
- Show a trailing clear action when `showClearButton == true`
- Wire `onSubmitted`, `onChanged`, `autofocus`, and `focusNode`
- Respect `maxLines`, defaulting to `1` when omitted

When `maxLines` is greater than `1`, the field may grow vertically, but the surrounding search chrome should remain visually consistent and keep trailing actions vertically centered.

## Visual Alignment Requirements

Search mode should match the app-level `VisirSearchBar` in these visible characteristics:

- Rounded outer container
- Border treatment and density
- Left accessory placement
- Compact text padding
- Right accessory spacing

Implementation should use `visir_ui` theme tokens and local Flutter widgets only. It must not import app-layer components such as `VisirButton`, `VisirIcon`, or app-specific context extensions.

## Internal Structure

Keep a single public `VisirInput` component.

Recommended internal structure:

- Shared constructor and prop surface at the widget level
- Internal branch for standard vs search presentation
- Small private helpers for border building and per-mode decoration/layout

This keeps the public API simple while avoiding a large, unreadable `build` method.

## Files To Change

### `ui/lib/src/components/visir_input.dart`

Add the new enum and props, and implement:

- Standard mode path
- Search mode path
- Shared helper methods where needed
- `maxLines` handling

### `ui/showcase/lib/sections/visir_input_section.dart`

Expand the showcase so developers can validate:

- Standard vs search mode
- Loading state
- Clear action visibility
- Custom leading widget
- `maxLines`

If snippet generation exists for the showcase, update it so generated examples reflect the new mode and props.

### Tests in the `ui` package

Add or update widget tests covering:

- Standard mode unchanged rendering expectations
- Search mode default leading icon
- Search mode accessory visibility rules
- `maxLines` behavior in both modes
- Callback wiring for clear and text events where practical

## Risks And Mitigations

### Risk: Standard mode regression

Mitigation:

- Keep the standard path structurally close to the current implementation
- Add tests for standard mode rendering and behavior

### Risk: Search mode overfits the current app search bar

Mitigation:

- Limit search-specific behavior to presentation and callback wiring
- Keep async state external
- Support custom `leading` and `maxLines`

### Risk: Mode-specific props create a confusing API

Mitigation:

- Default to standard mode
- Keep search props narrowly scoped
- Document that search props are mode-specific

## Verification Plan

- Run `ui` package tests covering `VisirInput`
- Validate the showcase renders both modes
- Confirm standard mode remains visually and behaviorally stable
- Confirm search mode visually matches the app search bar closely enough to replace it later without another design pass

## Implementation Boundary

This change stops at the reusable UI component and its showcase/tests.

Updating the app-level `VisirSearchBar` to consume the new `VisirInput` can be handled as a follow-up implementation task after the component contract is proven in the `ui` package.
