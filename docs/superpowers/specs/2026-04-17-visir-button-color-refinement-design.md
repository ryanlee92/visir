# Visir Button Color Refinement Design

## Goal

Improve `VisirButton` color readability with a narrow, button-only refinement:
- make `primary` foreground text and icons clearly readable
- make `danger` visibly more vivid crimson red

## Scope

This change applies to `VisirButton` color behavior only.

It will:
- keep the current button structure, sizing, hover, press, and focus behavior
- keep the current variant API unchanged
- retune foreground/background color behavior for `primary`
- retune the `danger` red to a more vivid crimson

It will not:
- redesign the full `Visir` color system
- broaden into a showcase-wide palette refresh
- change button motion, spacing, or interaction semantics
- intentionally redesign `secondary` or `ghost` beyond minor balancing if needed

## Design

### Primary button

`VisirButtonVariant.primary` should use a clearly readable white or near-white foreground for:
- label text
- icons
- loading spinner

The primary fill/gradient should be slightly deepened only as much as needed to support that foreground contrast. The goal is readability first, not a new visual direction.

### Danger button

`VisirButtonVariant.danger` should move from the current muted red toward a more vivid crimson red.

That refinement should preserve the existing polished `Visir` look:
- vivid and clearly destructive
- not muddy, pinkish, or washed out
- still consistent with the button family

The `danger` foreground should remain high-contrast and readable.

### Other variants

`secondary` and `ghost` should remain structurally unchanged in this pass.

Only minor balancing adjustments are acceptable if the updated `primary` or `danger` colors make them feel visually inconsistent, but this is not a redesign task for those variants.

## Implementation boundary

The preferred implementation is a targeted button color pass:
- update color math in `VisirButton`
- update shared token values only if those exact values are clearly the correct source of truth

This should stay as small as practical.

## Testing

Verification should confirm:
- `primary` foreground is clearly readable against the filled background
- `danger` is visibly more vivid red than before
- spinner tone and icon foreground still match the updated button colors
- hover, press, and focus behavior remain behaviorally unchanged

Implementation verification:
- `dart analyze ui/lib test/ui`
- `flutter test test/ui/components/visir_button_test.dart`
- `flutter test test/ui`

## Risks

The main risk is over-correcting color values and accidentally changing the overall `Visir` visual character.

Mitigation:
- keep the change button-only
- preserve the current interaction structure
- use the smallest color shift that fixes readability and danger clarity
