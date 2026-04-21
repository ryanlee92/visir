# Visir Showcase Sidebar Browser

## Goal

Replace the current scroll-and-jump showcase page with a two-pane component browser. The page should present a sidebar that groups every showcase component, and the main area should show one active component demo at a time.

## Proposed Structure

- Keep the existing `VisirAppBar` and theme toggle.
- Add a persistent sidebar on desktop that groups the showcase components by category.
- Show one active section in the main content area at a time.
- Keep each existing section widget as the source of truth for its preview, controls, and snippet.

## Section Groups

- `Actions`: `VisirButton`, `VisirIconButton`
- `Forms`: `VisirInput`
- `Surfaces`: `VisirCard`, `VisirSection`
- `Feedback`: `VisirSpinner`, `VisirDivider`
- `Status`: `VisirBadge`, `VisirEmptyState`

## Behavior

- The sidebar selection state lives in `ShowcasePage`.
- Selecting a sidebar item swaps the active section widget in the main pane.
- The active section remains mounted while selected so its local control state is preserved.
- The sidebar should show all components defined in the showcase registry.
- The page should remain usable on narrow screens. On small widths, the sidebar can collapse into a horizontal selector or another compact fallback that still exposes all components.

## Component Registry

The page should use a small registry object or table that provides:

- section id
- display title
- group/category
- widget builder

This registry should replace the current implicit section-order logic in the page shell.

## Non-goals

- Do not convert the showcase into route-based navigation.
- Do not refactor the section widgets themselves beyond any minimal integration needed for the shell.
- Do not redesign the component demos inside each section.
- Do not remove the theme toggle or app bar.

## Verification

- Add widget coverage for:
  - the sidebar rendering all component groups
  - selecting a sidebar item changes the visible active section
  - the active section keeps its state while selected
  - the mobile/compact fallback still exposes all components
- Run the `ui/showcase` test suite after implementation.
