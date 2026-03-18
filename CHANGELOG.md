# Changelog

All notable changes to AvenUI will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned
- Command Palette / Combobox
- Date Picker (with range selection)
- Chart components (VegaLite + Chart.js hooks)
- Drawer / Slideout panel
- Multi-select input
- File upload component
- Stepper / Wizard
- Color picker
- Rich text editor integration (Trix / ProseMirror hook)

---

## [0.1.0] — 2024-01-01

### Added

**Phase 1 — Core components**
- `Button` — 6 variants, 5 sizes, loading spinner, icon slot
- `Badge` — 7 variants, dot indicator, 3 sizes
- `Alert` — 4 variants, dismissible, named icon/title/description slots
- `Card` — header/body/footer slots, interactive variant, padding control
- `Input` — full Phoenix.HTML.FormField integration, label/hint/error, prefix/suffix, select
- `Toggle` — accessible boolean switch, 3 sizes, form-native
- `Avatar` / `AvatarGroup` — initials or image, 5 sizes, 6 colors, stacking
- `Progress` — 5 colors, 5 sizes, label, show_value
- `Skeleton` — shimmer loader placeholder
- `Table` — sortable columns, stream support, hover actions, empty state
- `Pagination` — smart page range, prev/next, disabled states

**Phase 2 — Overlay + Navigation**
- `Modal` — focus trap, scroll lock, Escape-to-close, 5 sizes, LiveView JS hide animation
- `Dropdown` — keyboard navigation, groups, labels, checkmarks, chevron auto-rotation
- `Tabs` — underline/pills/boxed variants, URL-patch mode, content panels, badge counts
- `Toast` / `flash_group` / `flash_banner` — auto-dismiss, PubSub-ready, Phoenix Flash native

**Phase 3 — Utilities + Layout**
- `Accordion` — pure LiveView JS, bordered/flush variants, open by default support
- `Stat` — KPI metric cards with trend arrows, prefix/suffix, loading state
- `Separator` — horizontal/vertical, labeled divider
- `Kbd` — keyboard shortcut styling
- `Spinner` — 5 sizes, inherits color
- `EmptyState` — icon, title, description, action slot
- `CodeBlock` — language label, copy button (CopyToClipboard hook)

**JS Hooks**
- `Flash` — auto-dismiss with pause-on-hover
- `Dropdown` — keyboard navigation, outside-click close
- `Modal` — focus trap, scroll lock, Escape
- `Tooltip` — position-aware, keyboard accessible
- `AutoResize` — growing textarea
- `CopyToClipboard` — clipboard API with visual feedback
- `InfiniteScroll` — IntersectionObserver sentinel
- `ScrollTop` — smooth scroll on LiveView patch

**Infrastructure**
- CSS design token layer with full dark mode (CSS variables, zero FOUC)
- Tailwind config preset (v3 + v4 compatible)
- `mix aven_ui.add` — shadcn-style component installer with namespace rewriting
- Storybook-style documentation site with live previews, code tabs, props tables
- `AvenUI.Helpers.classes/1` — conditional class merging utility
