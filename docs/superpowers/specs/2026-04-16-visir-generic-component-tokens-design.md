# Visir Generic Component Tokens Migration

## Goal

Replace component-local sizing and interactive border decisions with a generic, role-based component token system that is shared across the `ui` library and the `ui/showcase` app.

## Why

The current `ui` library mixes concerns:
- some decisions live in generic foundation tokens
- some live in `VisirButtonThemeData`
- some are still hardcoded directly inside widgets

That makes it harder to keep behavior and sizing consistent across components. It also encourages new components and the showcase shell to invent local rules instead of consuming one shared system.

## Scope

This migration covers:
- `ui/lib/src/theme/`
- `ui/lib/src/foundation/` where needed for shared token plumbing
- all current `ui` components:
  - `VisirButton`
  - `VisirIconButton`
  - `VisirInput`
  - `VisirCard`
  - `VisirBadge`
  - `VisirSection`
  - `VisirDivider`
  - `VisirSpinner`
  - `VisirEmptyState`
- `ui/showcase/` shell and section layouts where component-like sizing or surface decisions should come from the shared token system

This migration does not change public component APIs to accept arbitrary numeric values.

## Token Architecture

Introduce a generic component token layer organized by role instead of by concrete widget.

### Control Tokens

Used by interactive controls such as buttons, icon buttons, and inputs.

Responsibilities:
- heights mapped by shared size enums
- control horizontal padding
- control icon spacing and compact inline spacing
- interactive border states:
  - base
  - hover
  - focus
  - disabled
- interaction weight distinctions so stronger and lighter hover treatments are tokenized rather than hardcoded in widget logic

### Surface Tokens

Used by larger containers and layout surfaces such as cards, sections, and showcase panels.

Responsibilities:
- surface padding and density scales
- surface radii
- surface border treatments
- elevation and glow values where the system uses them

### Content Tokens

Used by inline or compact content elements such as badges and small text/icon relationships.

Responsibilities:
- inline paddings
- compact spacing relationships
- compact radii where needed
- content sizing hooks for small-format UI elements

### Feedback Tokens

Used by feedback-oriented elements such as spinners and lightweight state emphasis.

Responsibilities:
- feedback sizing hooks
- state emphasis values
- lightweight presentation values that should stay consistent across components

## Component Mapping

### Controls

- `VisirButton`
  - size-specific height must come from generic control tokens
  - hover border must come from tokenized interaction states
  - focus border should also be read from tokens rather than constructed ad hoc
- `VisirIconButton`
  - must follow the same control token system as `VisirButton`
- `VisirInput`
  - control border, focus state, and vertical sizing should use the same control token language

### Surfaces

- `VisirCard`
  - density padding and border treatments should read from surface tokens
- `VisirSection`
  - spacing and surface-like framing should be aligned with surface tokens
- showcase panels and shell sections
  - should stop inventing local surface spacing where a reusable surface token applies

### Content and Feedback

- `VisirBadge`
  - should read compact sizing and padding from content tokens
- `VisirDivider`
  - should use shared lightweight content or surface border tokens where appropriate
- `VisirSpinner`
  - should read size mappings from feedback tokens
- `VisirEmptyState`
  - should align internal spacing and action spacing with shared content/surface token language where appropriate

## Theme Structure

The existing theme model should expand from button-specific component theming toward generic role-based component theming.

Direction:
- keep `VisirThemeData`
- evolve `VisirComponentThemes` into a holder for role-based token families
- keep the token data enum-driven and deterministic
- prefer explicit token objects over freeform maps so the system stays readable

The result should be that component widgets mostly map enum choices and state to predeclared token values instead of embedding numeric layout decisions inline.

## Showcase Integration

`ui/showcase/` should consume the same shared token system for:
- section surface framing
- preview panel spacing
- control panel spacing where the shell is representing reusable component structure

The showcase should still keep its editorial personality, but it should not drift from the token system when the shell is effectively acting like another component surface.

## Constraints

- no new public API that accepts arbitrary dimensions
- preserve existing enum-driven sizing and variants
- avoid token overgrowth that is not used by current components or showcase shell
- keep each token family understandable and clearly named
- prefer migrating real call sites over introducing speculative token structures

## Testing

Add or update tests so the migration proves that:
- button heights are theme-driven rather than hardcoded
- hover and focus border behavior is token-driven
- inputs and cards continue to render correctly after token migration
- showcase shell still renders and uses the shared tokenized component language without visual regressions in structure-sensitive areas

## Success Criteria

This migration is successful when:
- size and border behavior for interactive controls is tokenized
- current components consume the generic token system instead of duplicating local numeric rules
- the showcase shell uses the same shared component-token language where appropriate
- the public API remains enum-driven and understandable
