# Changelog

All notable changes to AvenUI are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.2.3] — 2026-03-24

### Added

- **`data_table/1` component** — rich data table with filter bar + server-side sort
  - Filter bar with `dt_search/1` and `dt_select/1` sub-components
  - Active filter chips with individual remove buttons
  - Server-side sort — fires `phx-click` event, developer handles the query
  - Integrated pagination with row count ("Showing 1–20 of 243")
  - Empty state adapts: "No data yet" vs "No results match your filters"
  - `:toolbar` slot for action buttons (New, Export, etc.)
  - Row hover-reveal actions
- **`AvenUI.DataTable` struct** — state helper for filter/sort/pagination
  - `DataTable.new/1` — create initial state
  - `DataTable.set_filter/2` — update filter params, strips blank values
  - `DataTable.toggle_sort/2` — flip sort direction or change field
  - `DataTable.set_page/2` / `reset_page/1` — pagination control
  - `DataTable.put_total/2` — set total count from database
  - `DataTable.total_pages/1`, `offset/1`, `filtered?/1`, `filter_value/2`

### Changed

- Component count: 23 → 24 (data_table)
- `mix aven_ui.add --all` now includes `data_table`
- `use AvenUI, :components` now imports `AvenUI.Components.DataTable`

### Usage

```heex
<.data_table id="users" rows={@rows} table={@table}
  title="Users" on_filter="dt_filter" on_sort="dt_sort" on_paginate="dt_paginate">
  <:filter>
    <.dt_search name="search" placeholder="Search users…" />
    <.dt_select name="status" prompt="All statuses"
      options={[{"Active", "active"}, {"Inactive", "inactive"}]} />
  </:filter>
  <:toolbar>
    <.button size="sm" phx-click="new_user">New user</.button>
  </:toolbar>
  <:col :let={u} label="Name" field="name" sortable><%= u.name %></:col>
  <:col :let={u} label="Email" field="email" sortable><%= u.email %></:col>
  <:action :let={u}>
    <.button size="xs" variant="ghost" phx-click="edit" phx-value-id={u.id}>Edit</.button>
  </:action>
</.data_table>
```

```elixir
# LiveView
alias AvenUI.DataTable

def mount(_, _, socket) do
  {:ok, socket |> assign(:table, DataTable.new(per_page: 20)) |> load_rows()}
end

def handle_event("dt_filter", params, socket) do
  table = socket.assigns.table |> DataTable.set_filter(params) |> DataTable.reset_page()
  {:noreply, socket |> assign(:table, table) |> load_rows()}
end

def handle_event("dt_sort", %{"field" => field}, socket) do
  table = DataTable.toggle_sort(socket.assigns.table, field)
  {:noreply, socket |> assign(:table, table) |> load_rows()}
end

def handle_event("dt_paginate", %{"page" => page}, socket) do
  table = DataTable.set_page(socket.assigns.table, String.to_integer(page))
  {:noreply, socket |> assign(:table, table) |> load_rows()}
end
```

---

## [0.2.2] — 2026-03-23

### Added

- **DatePicker component** (`date_picker/1`) — calendar-based date input
  - Single date mode and date range mode (`mode="range"`)
  - Server-rendered calendar grid — no JS date library required
  - Month navigation via LiveView events
  - `min_date` / `max_date` constraints
  - Works with `Phoenix.HTML.FormField`
  - Built-in label, hint, error display, today shortcut, clear button
- **`AvenUIDatePicker` JS hook** — open/close and clear button wiring
- **`mix aven_ui.new` project generator**
  - Runs `mix phx.new` then wires AvenUI automatically
  - Installs all 23 components via `mix aven_ui.add --all`
  - Configures `app.css` for Tailwind v4
  - Wires `AvenUIHooks` into `app.js`
  - Injects component imports into `web.ex`
  - Starter layout: navbar + sidebar + dashboard home page
  - Dark mode toggle wired out of the box

### Changed

- Component count: 22 → 23
- `mix aven_ui.add --all` now includes `date_picker`

### Usage

```bash
# Project generator
mix aven_ui.new my_app
mix aven_ui.new my_saas --no-ecto
cd my_app && mix phx.server
```

```heex
# Single date picker
<.date_picker id="dob" name="dob" label="Date of birth"
  selected={@date} view_month={@dp_month} on_change="date_picked" />

# Date range picker
<.date_picker id="stay" name="stay" label="Stay dates" mode="range"
  range_start={@check_in} range_end={@check_out}
  view_month={@dp_month} on_change="date_picked" />
```

---

## [0.2.1] — 2026-03-23

### Added

- **Combobox component** (`combobox/1`) — searchable select field
  - Client-side filtering for static option lists (instant, no server round-trip)
  - Server-side search via `on_search="event_name"` + `phx-debounce`
  - Works with `Phoenix.HTML.FormField` (`field={@form[:country]}`)
  - Built-in label, hint, and error display
  - Accessible: `role="listbox"`, `role="option"`, `aria-expanded`, `aria-selected`
- **`AvenUICombobox` JS hook** — keyboard navigation for the combobox
  - `ArrowDown` / `ArrowUp` — navigate options
  - `Enter` — select highlighted option
  - `Escape` — close and return focus to trigger
  - Click outside to close
  - Fires native `change` event so `phx-change` works on the hidden input

### Changed

- `mix aven_ui.add --all` now includes `combobox`
- `use AvenUI, :components` now imports `AvenUI.Components.Combobox`
- Component count: 21 → 22

### Usage

```heex
<%# Static options — client filters instantly %>
<.combobox
  id="country"
  name="country"
  placeholder="Search countries…"
  options={[
    %{value: "th", label: "Thailand"},
    %{value: "sg", label: "Singapore"},
    %{value: "jp", label: "Japan"},
  ]}
  selected={@country}
/>

<%# Server-side search %>
<.combobox
  id="user"
  name="user_id"
  placeholder="Search users…"
  options={@users}
  selected={@user_id}
  on_search="search_users"
/>
```

---

## [0.2.0] — 2026-03-22

### Added

- **Tailwind v4 / Phoenix 1.8 support** — `avenui.css` now includes
  a `@theme {}` block that registers all `avn-*` tokens as native
  Tailwind v4 utilities (`bg-avn-purple`, `text-avn-foreground`,
  `rounded-avn-lg`, `shadow-avn`, etc.)

### Changed

- **Dropped Tailwind v3 support** — AvenUI now requires Tailwind v4
  and Phoenix 1.8+
- `tailwind.config.js` removed — no longer needed with Tailwind v4
- `avenui.css` restructured with `@layer base` and `@layer components`
  for correct Tailwind v4 cascade layer integration
- Dark mode tokens moved to `@layer base` (correct v4 approach)
- `mix aven_ui.add` next-steps output updated to show v4 CSS setup

### Migration from 0.1.x → 0.2.0

Update `assets/css/app.css` — replace the old three imports:

```css
/* Remove: */
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";

/* Replace with: */
@import "tailwindcss";
@import "../../deps/aven_ui/assets/css/avenui.css";
@source "../../deps/aven_ui/lib";
```

Delete `assets/tailwind.config.js` — not needed in Tailwind v4.

---

## [0.1.1] — 2026-03-20

### Changed

- Improved README with accessibility documentation and component count
- Updated hex.pm description to clarify the shadcn-style code ownership model

---

## [0.1.0] — 2026-03-18

### Added

- Initial release — 21 Phoenix LiveView components:
  Accordion, Alert, Avatar, Badge, Button, Card, CodeBlock,
  Dropdown, EmptyState, Input, Kbd, Modal, Progress, Separator,
  Skeleton, Spinner, Stat, Table, Tabs, Toast, Toggle
- 8 JS hooks: Dropdown, Modal, Tooltip, Flash, AutoResize,
  CopyToClipboard, InfiniteScroll, ScrollTop
- `mix aven_ui.add` — shadcn-style installer, copies source into your project
- `mix aven_ui.list` — lists all available components
- CSS design tokens with full dark mode support
- Tailwind preset via `assets/tailwind.config.js`
- MIT license
