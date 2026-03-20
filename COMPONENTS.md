# AvenUI Component Reference

21 components across 5 categories.

## Actions

| Component | File          | Functions                                                                                                             |
| --------- | ------------- | --------------------------------------------------------------------------------------------------------------------- |
| Button    | `button.ex`   | `button/1`, `button_icon/1`                                                                                           |
| Dropdown  | `dropdown.ex` | `dropdown/1`, `dropdown_item/1`, `dropdown_separator/1`, `dropdown_label/1`, `dropdown_check/1`, `dropdown_chevron/1` |

## Display

| Component | File          | Functions                    |
| --------- | ------------- | ---------------------------- |
| Avatar    | `avatar.ex`   | `avatar/1`, `avatar_group/1` |
| Badge     | `badge.ex`    | `badge/1`, `badge_dot/1`     |
| Progress  | `progress.ex` | `progress/1`                 |
| Skeleton  | `skeleton.ex` | `skeleton/1`                 |
| Stat      | `stat.ex`     | `stat/1`                     |

## Feedback

| Component | File       | Functions                                    |
| --------- | ---------- | -------------------------------------------- |
| Alert     | `alert.ex` | `alert/1`                                    |
| Toast     | `toast.ex` | `toast/1`, `flash_group/1`, `flash_banner/1` |

## Overlay

| Component | File       | Functions |
| --------- | ---------- | --------- |
| Modal     | `modal.ex` | `modal/1` |

## Layout

| Component | File           | Functions                                      |
| --------- | -------------- | ---------------------------------------------- |
| Accordion | `accordion.ex` | `accordion/1`                                  |
| Card      | `card.ex`      | `card/1`, `card_title/1`, `card_description/1` |

## Navigation

| Component | File      | Functions |
| --------- | --------- | --------- |
| Tabs      | `tabs.ex` | `tabs/1`  |

## Forms

| Component | File        | Functions             |
| --------- | ----------- | --------------------- |
| Input     | `input.ex`  | `input/1`, `select/1` |
| Toggle    | `toggle.ex` | `toggle/1`            |

## Data

| Component | File       | Functions                 |
| --------- | ---------- | ------------------------- |
| Table     | `table.ex` | `table/1`, `pagination/1` |

## Utilities

| Component   | File             | Functions       |
| ----------- | ---------------- | --------------- |
| Code Block  | `code_block.ex`  | `code_block/1`  |
| Empty State | `empty_state.ex` | `empty_state/1` |
| Kbd         | `kbd.ex`         | `kbd/1`         |
| Separator   | `separator.ex`   | `separator/1`   |
| Spinner     | `spinner.ex`     | `spinner/1`     |

## JS Hooks (8 total)

| Hook              | Purpose                           |
| ----------------- | --------------------------------- |
| `Dropdown`        | Keyboard nav, outside-click close |
| `Modal`           | Focus trap, scroll lock, Escape   |
| `Tooltip`         | Position-aware tooltip            |
| `Flash`           | Auto-dismiss with pause-on-hover  |
| `AutoResize`      | Growing textarea                  |
| `CopyToClipboard` | Clipboard with visual feedback    |
| `InfiniteScroll`  | Load-more on sentinel visible     |
| `ScrollTop`       | Smooth scroll on LiveView patch   |

```

---

## Step 4 — Open GitHub issues as roadmap (10 min)

Go to your GitHub repo → Issues → New Issue. Create these one by one:
```

Title: [v0.2] Combobox / searchable select
Label: enhancement, roadmap
Body:
Searchable dropdown with filtering. The #1 missing component
for real forms. Will use LiveView JS + phx-change for filtering.

---

Title: [v0.2] Date picker
Label: enhancement, roadmap
Body:
Calendar-based date input. Server-rendered month grid,
LiveView assigns for selected date and open/closed state.

---

Title: [v0.2] Tailwind v4 support
Label: enhancement, roadmap
Body:
Phoenix 1.8 ships with Tailwind v4 by default.
Migrate CSS tokens from :root {} to @theme {} syntax.
Remove tailwind.config.js in favor of CSS-first config.

---

Title: [v0.2] mix aven_ui.new generator
Label: enhancement, roadmap
Body:
`mix aven_ui.new my_app` scaffolds a full Phoenix 1.8 app
with AvenUI pre-installed, Tailwind v4 configured,
dark mode working, and a starter layout ready to go.

---

Title: [v0.2] Data table with server-side filter + sort
Label: enhancement, roadmap
Body:
Extend the current Table component with a filter bar,
column sort state, and full phx-update="stream" support.
The flagship data component.
