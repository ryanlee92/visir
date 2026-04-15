---
title: Visir UI Showcase Shell Design
date: 2026-04-15
status: draft
author: Codex
---

## Summary

Task 2 of the ui showcase worktree needs an editorial, single-page shell that frames future Visir component sections. This spec describes how the app-level theme, single-page layout, hero, navigation, and placeholder sections will align with the approved plan without building any actual component UI yet.

## Requirements

1. Theme should use Material 3 with a light scaffold background `#F6F0E8` and dark text `#17161A`.
2. Smoke test assertions must verify the new hero copy and jump navigation labels.
3. ShowcasePage must render a single scrollable column (no routing) with:
   - Hero titles (`Visir UI`, `Live Visir component playground`)
   - Jump navigation row with entries for `Jump to Button` and `Jump to Input` at minimum
   - Placeholder containers for each canonical component section.
4. Placeholder sections must be labeled so the jump navigation has actual targets.
5. Colors, spacing, and typography should feel editorial without yet drawing real components.

## Architecture & Layout

1. **ShowcaseTheme**: `ShowcaseTheme.build()` returns ThemeData configured with:
   - `useMaterial3: true`
   - Light color scheme seeded around `Color(0xFFF6F0E8)` and `Color(0xFF17161A)`
   - Consistent typography (e.g., `displaySmall` for hero, `bodyLarge` for callouts)

2. **ShowcaseApp**: Stateless widget that applies `ShowcaseTheme.build()` to a MaterialApp, hides the debug banner, and sets `ShowcasePage` as the home.

3. **ShowcasePage**:
   - Wraps content in `SingleChildScrollView` with a vertical `Column`.
   - At the top, renders:
     - Hero title `Visir UI` (bold, large)
     - Subtitle `Live Visir component playground`
     - Jump navigation row with `TextButton` for each section id in `showcaseSectionIds` and to highlight `Jump to Button` and `Jump to Input`
   - Each section is represented by a `SectionPlaceholder` widget (not implemented yet) that contains:
     - Heading text of the section slug (e.g., `Button`, `Icon Button`)
     - Short description or subheading
     - Light gray background, modest padding, and consistent spacing
   - Section placeholders are keyed (e.g., `GlobalKey`) so `TextButton` jumps can call `Scrollable.ensureVisible`.

## Navigation & Sections

- `showcaseSectionIds` constant lists: `button`, `icon-button`, `input`, `card`, `badge`, `section`, `divider`, `spinner`, `empty-state`.
- Jump row only renders a subset of these labels (minimum Jump to Button/Input) to satisfy the smoke test while leaving room for future entries.
- Placeholder containers map directly to `showcaseSectionIds` so each jump can target its own labeled section.

## Verification Plan

1. Update `showcase_smoke_test.dart` to expect the hero and navigation texts before running the failing test.
2. After implementation, run `flutter test` for the updated smoke test and `flutter build web --release`.

Once the user confirms this doc, it will be committed along with the code changes for Task 2.
