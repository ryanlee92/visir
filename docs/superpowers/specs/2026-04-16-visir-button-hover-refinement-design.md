# Visir Button Hover Refinement

## Goal

Bring `ui` button hover feedback closer to the legacy `VisirButton` feel without undoing the cleaner `ui` API or the recently restored press behavior.

## Scope

This change is limited to hover rendering in `ui/lib/src/components/visir_button.dart`.

It does not change:
- the public `VisirButton` API
- enum names or constructor parameters
- press behavior, which should remain shrink + opacity dim
- disabled and focus interaction rules

## Problem

The current `ui` button now separates hover from press correctly, but the hover visuals still differ from the legacy button.

Legacy hover behavior relied on:
- a dedicated inner hover overlay layer
- a clearer hover border treatment
- no hover-driven scale animation

The current `ui` hover treatment approximates that feel with broader surface and glow changes, which makes the interaction read differently in the showcase.

## Design

Use a split hover model by variant.

### Primary and Secondary

For `VisirButtonVariant.primary` and `VisirButtonVariant.secondary`:
- keep the current outer shell
- add a dedicated inner hover overlay layer
- apply a stronger hover border than the base border
- preserve the existing press-only scale and opacity feedback

This should visually match the legacy button more closely, where hover feels like a surface wash rather than a transform.

### Ghost and Danger

For `VisirButtonVariant.ghost` and `VisirButtonVariant.danger`:
- keep hover feedback lighter than `primary` and `secondary`
- use a softer overlay alpha and border shift
- avoid the denser legacy treatment so these variants keep a lighter visual identity

## Rendering Structure

The button visual stack should be conceptually split into:
- outer shell: base surface, border, shadow
- inner hover overlay: variant-specific translucent wash
- content layer: label, icons, loading spinner

This keeps hover styling isolated and makes the behavior easier to reason about than folding everything into a single `BoxDecoration`.

## Testing

Update or add widget coverage for:
- `primary` hover changes overlay and border without changing layout or scale
- `secondary` hover follows the same stronger legacy-style hover model
- `ghost` hover remains lighter than `secondary`
- `danger` hover remains lighter than `secondary`
- press feedback still shrinks and dims
- disabled buttons still do not react to hover

## Constraints

- Keep the implementation local unless one additional internal theme token is clearly justified
- Do not add new public customization props
- Preserve current semantics, focus handling, and disabled behavior
