# Visir Control Components Token Migration Design

## Goal
Migrate Visir control components (button, icon button, input) to consume
`theme.components.control` sizing and border tokens, while fixing known
hover/press regressions in the button tests. Add explicit tests proving that
control sizing and borders resolve from role tokens.

## Scope
- Update `VisirButton`, `VisirIconButton`, and `VisirInput` to read sizing and
  interactive border behavior from `theme.components.control`.
- Add tests that explicitly assert control sizing and border resolution from
  injected control tokens.
- Preserve existing component structure and semantics; no new theme classes.

Out of scope:
- Broad refactors outside the specified files.
- Changes to other component token definitions beyond consumption.

## Architecture / Approach
- Keep component logic in place.
- Replace hardcoded button heights/padding with `control.sizing` values.
- Replace focus/hover/disabled border styling in button/input with
  `control.borders` values and `control.radius`.
- Keep hover/press interaction logic in `VisirButton`, but ensure it aligns with
  current test expectations: hover does not scale; press shrinks and dims.

## Data Flow
- `VisirTheme.of(context)` provides `components.control`.
- `VisirButton` resolves:
  - height and horizontal padding from `control.sizing`.
  - border color/width from `control.borders` based on focus/hover/disabled.
  - radius from `control.radius`.
- `VisirInput` resolves border states similarly from `control.borders` and
  `control.radius`.

## Testing Strategy
- Add failing tests in button/supporting components suites for control-driven
  sizing and borders with explicit token values injected via `VisirTheme`.
- Keep comparative overlay tests for variant hover behavior unchanged.
- Run targeted `flutter test test/ui/components/...` before and after.

## Error Handling / Edge Cases
- Disabled interactions should clear hover/press state and use disabled border.
- Focused state should take precedence for focus border width/color.
- Hover state should only affect border when enabled and not focused.

