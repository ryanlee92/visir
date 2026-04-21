# VisirInput label and border contract

## Goal

Adjust `VisirInput` so the label becomes optional, and add a token-driven border mode with `none` as the default.

## Proposed API

- Keep `label` as an optional prop.
- Add `VisirInputBorder` with:
  - `none`
  - `base`
  - `success`
  - `error`
- Add a `border` prop to `VisirInput` that defaults to `VisirInputBorder.none`.

## Behavior

- When `label` is provided, render it above the shell using the shared text theme.
- When `label` is omitted, render only the shell and text field.
- The shell remains responsible for padding, radius, and border styling.
- The inner `TextField` stays raw:
  - no label decoration
  - no border decoration
  - no shell styling
- Border color comes from the token theme:
  - `none` renders no border
  - `base` uses the normal control border token
  - `success` uses the success token
  - `error` uses the danger token
- `errorText` automatically forces the effective border state to `error`.
- If `errorText` is empty or null, the explicit `border` prop controls the shell border.

## Component Scope

- `VisirInput` stays a single reusable shell component.
- Search-style usage continues to work through the same component.
- The showcase input section should be updated to demonstrate:
  - optional label
  - border states
  - automatic error border behavior

## Verification

- Add widget coverage for:
  - omitted label rendering
  - label rendering when provided
  - default borderless shell
  - base/success/error border tokens
  - automatic error border override
- Run the `ui` and `ui/showcase` test suites after implementation.
