# VisirCard Border Contract

## Goal

Add an explicit token-driven border mode to `VisirCard` so outlined and muted cards can opt into the base border token while elevated cards remain borderless by default.

## Proposed API

- Keep `variant` as the visual mode for the card surface.
- Add `VisirCardBorder` with:
  - `none`
  - `base`
- Add a `border` prop to `VisirCard` that defaults to `VisirCardBorder.none`.

## Behavior

- `VisirCardVariant.elevated` stays borderless regardless of the `border` prop.
- `VisirCardVariant.muted` and `VisirCardVariant.outlined` can render a token-driven base border when `border == VisirCardBorder.base`.
- When `border == VisirCardBorder.none`, no border is rendered for any variant.
- Existing padding, radius, semantic wrapping, focus treatment, and elevation behavior remain unchanged.
- Interactive cards continue to use the existing focus shadow treatment layered on top of the variant-specific base shadow.

## Component Scope

- `VisirCard` remains a single reusable card surface component.
- The showcase card section should be updated to demonstrate the new border toggle only for the variants that support it.

## Verification

- Add widget coverage for:
  - elevated cards staying borderless
  - muted and outlined cards rendering the base token border when enabled
  - default borderless behavior for all variants
  - focus treatment still applying on interactive cards
- Run the `ui` and `ui/showcase` test suites after implementation.
