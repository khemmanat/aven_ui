# Changelog

## [0.2.0] — 2026-03-21

### Added

- **Tailwind v4 / Phoenix 1.8 support** — `avenui.css` now includes
  a `@theme {}` block that registers all `avn-*` tokens as native
  Tailwind v4 utilities (`bg-avn-purple`, `text-avn-foreground`, etc.)
- Dual compatibility — works with both Tailwind v3 and v4 in the same file

### Changed

- `avenui.css` restructured with `@layer base`, `@layer components`
  for correct Tailwind v4 cascade layer integration
- `tailwind.config.js` updated — now clearly marked as v3-only with
  v4 migration instructions at the top
- Dark mode tokens now defined in `@layer base` (correct v4 approach)

### Migration from 0.1.x to 0.2.0

**Tailwind v4 / Phoenix 1.8 — update your `app.css`:**

```css
/* Remove the old three-line import */
/* @import "tailwindcss/base";       */
/* @import "tailwindcss/components"; */
/* @import "tailwindcss/utilities";  */

/* Replace with: */
@import "tailwindcss";
@import "../../deps/aven_ui/assets/css/avenui.css";
@source "../../deps/aven_ui/lib/**/*.ex";
```

And remove `tailwind.config.js` from your project (no longer needed).

**Tailwind v3 / Phoenix 1.7 — no changes required.**
Existing setup continues to work exactly as before.

---

## v0.1.1 — 2026-03-20

- Improved README with accessibility documentation
- Added COMPONENTS.md reference
- Updated hex.pm description with component count

## v0.1.0 — 2026-03-18

- Initial release
- 21 components: Button, Badge, Alert, Card, Modal, Dropdown,
  Tabs, Table, Toast, Accordion, Toggle, Avatar, Progress,
  Skeleton, Stat, Separator, Spinner, Kbd, EmptyState,
  CodeBlock, Input
- 8 JS hooks: Dropdown, Modal, Tooltip, Flash, AutoResize,
  CopyToClipboard, InfiniteScroll, ScrollTop
- shadcn-style installer: mix aven_ui.add
- CSS design tokens with full dark mode
- Tailwind preset
