# Visir UI Library Design

Date: 2026-04-15
Status: Draft approved in conversation, pending final user review of this file

## Goal

Create a new top-level Flutter UI library at `ui/` that contains `Visir`-prefixed components with a cleaner, more understandable API than the current in-app widgets.

The library must:

- live in top-level `ui/`
- be Flutter/Dart only
- include `VisirButton`
- preserve the existing `VisirButton` interaction feel as a behavioral reference
- use a cleaner public API than the current `style/options/type` pattern
- prefer enum-based choices over arbitrary numeric styling inputs
- ship with a `ui/README.md` that documents usage examples

The library will start in parallel with the existing app widgets. It is not a migration project in this phase.

## Non-Goals

- replacing current widgets under `lib/features/common/presentation/widgets`
- migrating the app to consume `ui/`
- supporting web/Svelte or the `branding` package
- exposing arbitrary per-instance styling knobs as the primary API
- building a live showcase page in v1

## Product Direction

### Platform

The library targets Flutter only.

### Placement

The library lives at top-level `ui/` and must not be nested under `branding/` or any `lib/` folder.

### Design Direction

The visual direction is the luminous or glass-like option selected during brainstorming:

- purple-led emphasis
- layered surfaces
- soft borders
- premium but readable contrast

This direction should be expressed consistently across buttons, cards, inputs, badges, and supporting components.

### Behavioral Reference

The new implementation is fresh, but it should copy the existing `VisirButton` user interaction model as closely as practical:

- hover response
- pressed response
- focus behavior
- disabled state
- loading state
- general motion feel

The new public API should not copy the old constructor shape.

## Architecture

The initial structure of `ui/`:

```text
ui/
  README.md
  visir_ui.dart
  src/
    foundation/
      visir_tokens.dart
      visir_colors.dart
      visir_spacing.dart
      visir_radius.dart
      visir_motion.dart
      visir_enums.dart
    theme/
      visir_theme.dart
      visir_theme_data.dart
      visir_component_themes.dart
    components/
      visir_button.dart
      visir_icon_button.dart
      visir_input.dart
      visir_card.dart
      visir_badge.dart
      visir_section.dart
      visir_divider.dart
      visir_spinner.dart
      visir_empty_state.dart
```

### Responsibilities

- `visir_ui.dart`
  Public export barrel for the library.
- `foundation/`
  Design tokens and enum definitions. This layer maps design decisions to fixed values.
- `theme/`
  Theme objects and inherited accessors used by components.
- `components/`
  Reusable public widgets.
- `README.md`
  Human-readable usage guide for the initial library.

## Starter Component Set

The first version should include:

- `VisirButton`
- `VisirIconButton`
- `VisirInput`
- `VisirCard`
- `VisirBadge`
- `VisirSection`
- `VisirDivider`
- `VisirSpinner`
- `VisirEmptyState`

This set is broad enough to establish a coherent UI language without turning the first implementation into a full design system rollout.

## API Design Principles

### Public API

Public constructors should be readable, conventional, and small. Components should expose semantic choices instead of low-level styling objects.

Example target API:

```dart
VisirButton(
  label: 'Continue',
  onPressed: () {},
  variant: VisirButtonVariant.primary,
  size: VisirButtonSize.md,
  leading: const Icon(Icons.add),
  trailing: const Icon(Icons.arrow_forward),
  isLoading: false,
  isExpanded: false,
  tooltip: 'Create item',
)
```

### Enum-Driven Choices

The public API should prefer enums over arbitrary numbers.

Examples:

- `VisirButtonSize.sm`, `VisirButtonSize.md`, `VisirButtonSize.lg`
- `VisirButtonVariant.primary`, `secondary`, `ghost`, `danger`
- `VisirCardVariant.elevated`, `muted`, `outlined`
- `VisirCardDensity.compact`, `comfortable`, `spacious`
- `VisirBadgeTone.neutral`, `primary`, `success`, `warning`, `danger`

Numeric tuning such as spacing, radius, height, icon size, and animation duration should be sourced from tokens inside the library rather than passed directly by callers in normal usage.

### Customization Model

Customization should happen in this order:

1. sensible defaults
2. semantic enum choices
3. library-level theme overrides

It should not default to per-instance arbitrary style values in the primary constructor API.

## Component Contracts

### VisirButton

Primary action component with the cleanest API in the library.

Initial public surface:

- `label`
- `onPressed`
- `variant`
- `size`
- `leading`
- `trailing`
- `isLoading`
- `isExpanded`
- `tooltip`
- `autofocus`
- `focusNode`

Behavior requirements:

- preserve existing Visir button interaction feel as the reference
- support enabled and disabled states
- show a loading treatment without changing layout unexpectedly
- keep sizing and spacing consistent per enum size
- support keyboard focus cleanly

### VisirIconButton

Icon-only companion to `VisirButton` using the same interaction engine and variant language where practical.

### VisirInput

Readable text input with an understandable API.

Initial public surface:

- `label`
- `hintText`
- `controller`
- `prefix`
- `suffix`
- `errorText`
- `enabled`

### VisirCard

Content container with consistent luminous surfaces and optional interactivity.

Initial public surface:

- `child`
- `variant`
- `density`
- `onTap`

### VisirBadge

Compact label for status and metadata.

Initial public surface:

- `label`
- `tone`

### VisirSpinner

Loading indicator that matches the library palette.

Initial public surface:

- `size`
- `tone`

### VisirEmptyState

Simple empty-state presentation with one primary action.

Initial public surface:

- `title`
- `description`
- `action`

### VisirSection and VisirDivider

Lightweight layout primitives used to keep pages visually consistent without requiring consumers to manually recreate spacing and separation patterns.

## Theme and Token Design

### VisirThemeData

`VisirThemeData` should hold the library design tokens:

- colors
- spacing
- radii
- shadows or elevations
- border treatments
- motion durations and curves
- component-specific token groups where needed

### VisirTheme

`VisirTheme` should expose `VisirThemeData` to descendants with sensible defaults so components work out of the box.

Apps may override the library theme, but theme setup must not be required for basic usage.

### Default Token Intent

The default theme should encode:

- a purple-led primary accent
- glass-like surfaces with readable contrast
- soft border radii
- subtle but visible state transitions

## Interaction Reuse Strategy

The new library should not directly duplicate the old public API, but it should study the current in-app `VisirButton` implementation and carry forward the parts that shape user experience.

The implementation should explicitly inspect and preserve:

- hover timing and visual response
- press animation timing and scale or opacity response
- focus handling
- disabled affordance
- tooltip behavior where applicable

Anything that exists only because of legacy structure should be omitted from the new library.

## Documentation

`ui/README.md` should explain:

- what the library is for
- how to import it
- the first component set
- example usage for `VisirButton`
- example usage for key supporting widgets
- the enum-based customization model

The README should be sufficient for a developer to adopt the library without reading internals first.

## Testing Strategy

Testing will follow TDD during implementation.

Initial required coverage:

- `VisirButton` widget tests for variant rendering
- `VisirButton` widget tests for size rendering
- `VisirButton` widget tests for hover behavior
- `VisirButton` widget tests for pressed behavior
- `VisirButton` widget tests for disabled behavior
- `VisirButton` widget tests for loading behavior
- basic render tests for the starter components

The button is the highest-priority behavioral component and should receive the strongest early test coverage.

## Implementation Boundaries

Phase 1 implementation should focus on creating a coherent, documented library with the starter components and theme foundation.

It should avoid:

- broad app refactors
- silent replacement of existing widgets
- one-off customization escape hatches
- adding many extra variants before the base language is stable

## Open Decisions Resolved In This Spec

- library location: `ui/`
- platform: Flutter
- initial role: parallel library, not migration
- visual direction: luminous or glass-like option A
- button behavior source: existing user interaction model
- public API style: clean semantic constructors
- sizing and styling model: enums and tokens, not arbitrary numbers
- documentation format: `ui/README.md`, no live showcase in v1

## Success Criteria

The first implementation is successful if:

- `ui/` exists as a clear top-level Flutter library
- `VisirButton` is implemented with a cleaner API
- the existing interaction feel is recognizably preserved
- the starter component set shares a coherent visual language
- consumers can use the library through enums and defaults instead of raw numeric styling
- `ui/README.md` makes the library understandable without code archaeology
