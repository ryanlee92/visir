# VisirCard Border and Shadow Contract

## Goal

Add explicit border and elevation toggles to `VisirCard` so muted and outlined cards can opt into the base token border, while elevation shadow can be disabled independently.

## Proposed API

- Keep `variant` as the primary card surface mode.
- Add `VisirCardBorder` with:
  - `none`
  - `base`
- Add a `border` prop to `VisirCard` that defaults to `VisirCardBorder.none`.
- Add a `showShadow` prop to `VisirCard` that defaults to `true`.

## Behavior

- `VisirCardVariant.elevated` remains borderless by default.
- `VisirCardVariant.muted` and `VisirCardVariant.outlined` can render the base token border when `border == VisirCardBorder.base`.
- When `border == VisirCardBorder.none`, no border is rendered for any variant.
- `showShadow: false` removes only the elevation shadow.
- Interactive focus treatment remains unchanged and still applies when the card is focusable.
- Existing padding, radius, semantic wrapping, and keyboard/mouse activation behavior remain unchanged.

## Component Scope

- `VisirCard` remains a single reusable surface component.
- The showcase card section should be updated to demonstrate the new border toggle and the shadow toggle.

## Verification

- Add widget coverage for:
  - elevated cards staying borderless
  - muted and outlined cards rendering the base token border when enabled
  - default borderless behavior
  - elevation shadow toggling off without removing the focus treatment
- Run the `ui` and `ui/showcase` test suites after implementation.
