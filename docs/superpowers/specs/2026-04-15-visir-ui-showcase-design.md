# Visir UI Showcase Design

## Overview

This spec defines a standalone showcase website for the new top-level `ui/`
library. The showcase exists to help internal developers understand and use the
`Visir` component API by interacting with live examples instead of reading
source files in isolation.

The showcase must live at `ui/showcase/` as its own Flutter web app. It is
parallel to the main app and parallel to the older `branding/` site. It must
not depend on `branding/`, and it must not reintroduce `branding/` as part of
the new developer-facing entrypoint for the component system.

## Goals

- Provide a clear, attractive single-page website for exploring the `ui/`
  library.
- Let internal developers manipulate almost every public prop for each
  showcased component.
- Show curated code snippets that update with the live control state.
- Preserve the `Visir` visual language while giving the showcase itself a more
  editorial, microsite-like shell.
- Keep the showcase isolated as a standalone Flutter web app under
  `ui/showcase/`.

## Non-Goals

- Replacing the main app.
- Replacing the older `branding/` work.
- Publishing the showcase as a public documentation site in v1.
- Building a metadata-heavy generic docsite engine before the first useful
  version exists.
- Supporting every possible private or internal implementation detail from the
  widgets. The showcase is for the public `ui/` API surface.

## Audience

Primary audience: internal developers using the `Visir` library in this repo.

The site should optimize for:

- quick understanding of component behavior
- quick discovery of enum-driven options
- copy-pasteable usage snippets
- visual confidence when changing props and states

It does not need to optimize equally for external consumers, marketing, or
design-only review.

## Product Decisions

- Location: `ui/showcase/`
- Runtime: standalone Flutter web app
- Navigation: single-page gallery with jump navigation
- Presentation style: editorial and bold, closer to a microsite than a neutral
  docs shell
- Interaction model: playground-oriented
- Control depth: expose almost every public prop that makes sense
- Snippets: included and visible beside live examples
- Audience: internal developers first

## Why This Shape

The `ui/` library already uses a clean, enum-driven public API and lives
outside normal `lib/` packaging. The fastest path to a useful showcase is a
standalone app physically colocated with the library, using Flutter web so the
rendered examples are the real widgets rather than approximations.

A single-page structure matches the user preference and keeps the first version
simple to navigate. An editorial shell gives the site a stronger identity than
an internal utility page while still letting the actual `Visir` components stay
central.

## High-Level Architecture

The showcase should be a dedicated Flutter app with its own `pubspec.yaml`,
entrypoint, and web target, but should import the repo-local `ui/` library via
relative imports.

At a high level:

- `ui/showcase/` owns app bootstrapping, page layout, and showcase-specific
  controls
- `ui/` remains the source of truth for all `Visir` components and tokens
- each showcased component gets a dedicated section widget
- reusable playground controls and snippet rendering live in shared showcase
  support files

This is intentionally not a routing-heavy app. Even though it is implemented as
independent widgets internally, the public experience should feel like one
continuous page.

## File Structure

Planned structure:

- `ui/showcase/pubspec.yaml`
  Standalone Flutter package configuration.

- `ui/showcase/web/`
  Flutter web host files for the showcase app.

- `ui/showcase/lib/main.dart`
  Entrypoint for the showcase application.

- `ui/showcase/lib/app/showcase_app.dart`
  App root, theming, and top-level shell wiring.

- `ui/showcase/lib/app/showcase_page.dart`
  The main single-page layout that assembles all sections.

- `ui/showcase/lib/app/showcase_theme.dart`
  Showcase-specific shell styling for the editorial site chrome. This should
  complement `Visir` components rather than replace `VisirTheme`.

- `ui/showcase/lib/sections/`
  One section file per showcased component, for example:
  - `visir_button_section.dart`
  - `visir_icon_button_section.dart`
  - `visir_input_section.dart`
  - `visir_card_section.dart`
  - `visir_badge_section.dart`
  - `visir_section_section.dart`
  - `visir_divider_section.dart`
  - `visir_spinner_section.dart`
  - `visir_empty_state_section.dart`

- `ui/showcase/lib/playground/`
  Reusable controls and preview scaffolding, for example:
  - enum picker rows
  - boolean toggles
  - text controls
  - icon selection controls
  - snippet panel
  - preview frame

- `ui/showcase/lib/data/`
  Curated defaults, labels, preset values, and snippet helper logic.

- `ui/showcase/test/`
  Showcase-focused widget tests and helper tests.

## Page Layout

The website should be one continuous page with anchored sections.

Main page regions:

1. Hero
   Introduces `Visir UI`, explains that the site is a live playground for the
   repo-local component library, and gives quick jump links.

2. Jump navigation
   A compact section navigator for quickly jumping to components such as
   `VisirButton`, `VisirInput`, and `VisirCard`.

3. Repeated component sections
   Each component gets a consistent layout:
   - section heading
   - short usage guidance
   - live preview
   - controls panel
   - code snippet panel
   - optionally a few recommended presets

4. Footer/closing note
   Light internal guidance such as where the library source lives and how to
   import it in-repo.

The page must work cleanly on both desktop and narrower widths. On desktop, the
preview, controls, and snippets can sit side-by-side or in a two-column layout.
On mobile width, the layout should stack without becoming unreadable.

## Visual Direction

The showcase shell should be editorial and bold.

That means:

- strong typography hierarchy
- more atmosphere than a neutral docs app
- intentional backgrounds, gradients, or layered surfaces
- section rhythm that feels like a microsite

However, the shell must not fight the components. The `Visir` components should
still be the visual subject. The shell provides framing, not competition.

Practical implications:

- use distinctive page-level styling separate from `VisirTheme`
- keep demo surfaces controlled so contrast and spacing remain legible
- avoid visual noise that makes control panels or snippets harder to scan

## Component Coverage

The first showcase version should include the current `ui/` starter set:

- `VisirButton`
- `VisirIconButton`
- `VisirInput`
- `VisirCard`
- `VisirBadge`
- `VisirSection`
- `VisirDivider`
- `VisirSpinner`
- `VisirEmptyState`

Every listed component should have a visible section on the page in v1.

## Interaction Model

Each section should follow the same mental model so developers can learn the
site once and reuse that understanding everywhere.

Each section contains:

- a short explanation of when to use the component
- a live preview using the real `ui/` widget
- a control surface exposing most public props
- a code snippet generated from current state

The controls should be playground-oriented rather than preset-only. The user
explicitly asked to expose almost every public prop, so the site should provide
meaningful toggles or inputs for most constructor parameters.

That does not mean allowing nonsense configurations without guardrails.
Showcase controls should constrain clearly invalid or confusing combinations
where needed so the resulting preview stays understandable.

Examples:

- `VisirButton`
  - `label`
  - `variant`
  - `size`
  - enabled/disabled
  - `isLoading`
  - `isExpanded`
  - `tooltip`
  - `leading`
  - `trailing`

- `VisirIconButton`
  - `variant`
  - `size`
  - selected icon from a curated set
  - `semanticLabel`
  - enabled/disabled
  - `tooltip`

- `VisirInput`
  - `label`
  - `hintText`
  - prefix
  - suffix
  - `errorText`

- `VisirCard`
  - `variant`
  - `density`
  - interactive/non-interactive state

- `VisirBadge`
  - `label`
  - `tone`

- `VisirSpinner`
  - `size`
  - `tone`

Components with small APIs such as `VisirDivider` can use much simpler control
areas or even mostly static examples.

## Snippet Behavior

Snippets are part of the product, not an afterthought.

Requirements:

- snippets update as the control state changes
- snippets should be curated rather than mechanically dumping every prop
- default values should be omitted
- only meaningful props should appear
- snippets should reflect the clean public API, not internal implementation
  details

For example, if `VisirButtonVariant.primary` and `VisirButtonSize.md` are the
defaults, those props should be omitted unless the current preview changed them.

If a control state does not map to a clean example, the snippet generator should
choose the clearest equivalent valid snippet rather than printing noisy or
misleading code.

The snippets should prioritize readability for internal developers who want to
copy the pattern into app code.

## Data and State Strategy

The showcase should not start with a heavy generic schema engine.

Use simple typed state held per section:

- each section widget owns or is given a typed local state object
- reusable control widgets can update that state
- snippet helpers translate typed state into readable code strings

This keeps v1 easy to reason about and easy to evolve without over-abstracting.

Some reusable helpers are still worthwhile:

- enum to label mapping
- curated icon option lists
- prop filtering for snippet generation
- common preview panel/chrome widgets

## Theming and Composition

The showcased components should continue to render through the `Visir` library
itself. The showcase app should not duplicate component styling.

Expected composition:

- showcase shell theme controls the page chrome, typography, backgrounds, and
  layout
- `VisirTheme` remains responsible for the rendered `Visir` widgets
- preview frames should present components on consistent surfaces so changes are
  easy to compare

This separation matters. The showcase is demonstrating the library, not
re-implementing it.

## Integration Constraints

- `ui/showcase/` must be standalone with its own `pubspec.yaml`
- the app must run independently as a Flutter web app
- it should import `ui/` through repo-local relative paths
- it must not depend on `branding/`
- it must not require new main-app routes to exist

This preserves the clean parallel structure that the user explicitly requested.

## Testing Strategy

The showcase does not need exhaustive snapshot coverage, but it does need enough
tests to keep the playground logic trustworthy.

Required coverage:

- widget smoke test for the main showcase page rendering all expected sections
- focused tests for reusable playground controls where behavior matters
- focused tests for snippet generation helpers
- at least one high-value section test for `VisirButton`

Suggested examples:

- a snippet generator omits default props
- changing a `VisirButton` variant control updates both preview and snippet
- the showcase page renders all v1 component section headings

## Accessibility Expectations

Even though this is an internal showcase, it should not be treated as a throwaway
page.

Expectations:

- controls should be keyboard reachable
- section headings should create clear scan structure
- preview and snippet areas should remain legible on narrow widths
- generated snippets should be selectable and readable

## Risks and Mitigations

### Risk: Overbuilding the control system

If the showcase starts as a generic metadata framework, v1 will slow down
without improving actual developer understanding.

Mitigation:

- keep section state typed and direct in v1
- extract only small, obviously reusable control widgets

### Risk: The shell overwhelms the components

An editorial microsite can become visually louder than the actual demos.

Mitigation:

- keep preview frames disciplined and consistent
- use bold layout and atmosphere mostly at the page-shell layer

### Risk: Snippets become noisy or misleading

If snippet generation blindly mirrors state, the output can teach bad usage.

Mitigation:

- explicitly omit defaults
- curate prop inclusion rules
- keep icon choices and free-text props controlled

## Open Questions Resolved

- Showcase location: `ui/showcase/`
- Delivery platform: standalone Flutter web app
- Navigation: single-page
- Styling: editorial shell
- Playground depth: expose almost all public props that make sense
- Snippets: included for all major examples
- Audience: internal developers first

## Implementation Readiness

This spec is intentionally scoped to one implementation plan.

The work naturally decomposes into:

- app scaffold and shell
- shared playground/snippet infrastructure
- component sections
- tests and polish

No additional subsystem split is required before planning.
