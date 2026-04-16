# Visir Button Vertical Padding Design

## Goal

Change `VisirButton` from fixed/min-height-driven sizing to padding-driven sizing so each button size is defined by tokenized horizontal and vertical insets rather than a hardcoded outer height.

## Scope

This change applies to `VisirButton` behavior only.

It will:
- keep the public enum API unchanged (`VisirButtonSize.sm|md|lg`)
- keep hover, press, focus, disabled, loading, and icon-slot behavior unchanged
- replace button height token usage with vertical padding tokens

It will not:
- change `VisirInput` sizing behavior in this pass
- introduce arbitrary numeric constructor props
- broaden into a new generic token-system redesign beyond what the button needs

## Design

### Button sizing model

`VisirButton` should no longer rely on a tokenized `height` value for its layout.

Instead, each button size should resolve from shared control sizing tokens:
- `horizontalPadding`
- `verticalPadding`
- `iconSpacing`

The rendered height should be determined naturally by:
- text style
- icon or spinner content
- tokenized vertical padding

This preserves the existing size vocabulary while removing the rigid fixed-height feel.

### Token model

The shared control sizing token layer should move from:
- `height`
- `horizontalPadding`
- `iconSpacing`

to:
- `verticalPadding`
- `horizontalPadding`
- `iconSpacing`

`VisirButton` consumes all three.

This token change is shared infrastructure, but the behavior change in this spec is intentionally button-focused.

### Layout behavior

`VisirButton` should:
- remove the current button min-height constraint
- apply symmetric vertical padding inside the button content container
- keep horizontal padding tokenized by size
- keep icon spacing tokenized
- preserve the current tappable area via the padded button surface itself

`isExpanded` should continue to affect width only.

### Non-goals

This spec does not require:
- making all controls padding-driven
- introducing a new button size enum
- changing the existing button interaction model

## Testing

Update button tests so they validate the new sizing behavior:
- stop asserting fixed/min-height-driven sizing for `VisirButton`
- assert that size variants map to the expected vertical padding
- keep existing interaction tests covering hover, press, disabled, and loading behavior

Verification for implementation:
- `dart analyze ui test/ui`
- `flutter test test/ui/components/visir_button_test.dart`
- `flutter test test/ui`

## Risks

The main risk is accidental size drift in tests or in components that assumed a fixed button height.

Mitigation:
- keep the API unchanged
- keep the change local to button sizing
- update tests to lock the token-driven padding behavior explicitly
