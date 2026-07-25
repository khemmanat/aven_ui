# AvenUI — 29+ Phoenix LiveView Components

> Even if AvenUI stopped being maintained tomorrow, your app keeps
> working — because `mix aven_ui.add` copies the code into your project.
> You own it. No paywalls. Ever.

> Free alternative to Petal. MIT licensed. Tailwind v4 native.

---

## Why AvenUI?

- **29+ accessible Phoenix LiveView components** - Everything you need for modern web apps
- **shadcn-style installer** — `mix aven_ui.add button badge` copies source into your app
- **Ready in seconds** — `mix aven_ui.new my_app` scaffolds a fresh Phoenix app with AvenUI pre-wired
- **Tailwind v4 / Phoenix 1.8 native** — CSS-first setup, no config files required
- **Full dark mode** — Via design tokens, without class flicker
- **Form-native** — Works seamlessly with `Phoenix.HTML.FormField` and Ecto changesets
- **Rich data UI** — `combobox`, `date_picker`, `data_table`, `sidebar`, `steps`, `file_input`
- **Minimal JS** — Only where interaction is actually needed
- **Free forever** — MIT licensed, no paywalls, you own the code

## 🎉 New in v1.0.0

**5 Major New Components for Complete App Development:**
- `sidebar` — Responsive navigation with collapsible functionality for dashboards
- `breadcrumb` — Semantic navigation hierarchy display
- `tooltip` — Position-aware contextual help with keyboard accessibility
- `file_input` — Advanced drag-and-drop file upload with progress tracking
- `steps` — Multi-step wizard component for guided workflows

**2026 Compatibility:**
- ✅ Updated to Elixir 1.19 for latest 2026 standards
- ✅ Enhanced Phoenix 1.8+ and LiveView 1.1+ compatibility
- ✅ Modern component patterns and best practices
- ✅ Production-ready with zero compilation errors

**Previous Features (from v0.2.x):**
- `combobox` — searchable select with keyboard navigation
- `date_picker` — single-date and range picker with server-rendered calendar
- `data_table` — filter bar, server-side sort, pagination, and active filter chips
- `mix aven_ui.new` — Phoenix project generator with AvenUI pre-installed
- Tailwind v4 migration — CSS-first setup with native `@theme` tokens

## Accessibility

Every component ships with accessibility baked in:

- `role` and `aria-*` attributes where relevant
- Keyboard navigation for dropdowns, comboboxes, tabs, and date pickers
- Focus management for modal dialogs
- Screen-reader friendly flash toasts via `role="status"`
- Semantic table, form, and navigation markup

---

## 🚀 Quick Start (2 minutes)

**The easiest way to build modern Phoenix apps:**

```bash
# Step 1: Create new app with AvenUI pre-installed
mix aven_ui.new my_app
cd my_app

# Step 2: Start the server
mix phx.server

# That's it! You now have a full Phoenix app with:
# - 29+ components ready to use
# - Dark mode toggle
# - Responsive dashboard layout
# - Form handling
# - Data tables
# - All the modern UI features
```

**Or add to existing app (30 seconds):**

```bash
# Add dependency
mix deps.get

# Copy components you want
mix aven_ui.add button card input modal sidebar

# Start using immediately!
```

---

## Installation

### Option A — Start a new app with AvenUI

```bash
mix aven_ui.new my_app
cd my_app
mix phx.server
```

This generates a Phoenix app with:

- ✅ AvenUI v1.0.0 installed
- ✅ All 29+ components added
- ✅ Tailwind v4 CSS wired
- ✅ `AvenUIHooks` connected in `app.js`
- ✅ Starter dashboard layout with dark mode toggle
- ✅ Elixir 1.19 and Phoenix 1.8+ compatible

### Option B — Add AvenUI to an existing Phoenix app

### 1. Add the dependency

```elixir
# mix.exs
def deps do
  [
    {:aven_ui, "~> 1.0.0", hex: :aven_ui}
  ]
end
```

If you prefer GitHub:

```elixir
{:aven_ui, "~> 1.0.0", github: "khemmanat/aven_ui"}
```

### 2. Install components

```bash
mix deps.get

# Add specific components
mix aven_ui.add button badge alert card input tabs modal

# Or add everything
mix aven_ui.add --all

# Dry run — see what would be copied
mix aven_ui.add --all --dry-run
```

This copies component modules into `lib/my_app_web/components/ui/`, plus:

- `assets/css/avenui.css`
- `assets/js/hooks/aven_ui.js`

### 3. Import your copied components in `web.ex`

```elixir
# lib/my_app_web.ex
defp html_helpers do
  quote do
    import MyAppWeb.UI.Accordion
    import MyAppWeb.UI.Alert
    import MyAppWeb.UI.Avatar
    import MyAppWeb.UI.Badge
    import MyAppWeb.UI.Button
    import MyAppWeb.UI.Card
    import MyAppWeb.UI.CodeBlock
    import MyAppWeb.UI.Combobox
    import MyAppWeb.UI.DataTable
    import MyAppWeb.UI.DatePicker
    import MyAppWeb.UI.Dropdown
    import MyAppWeb.UI.EmptyState
    import MyAppWeb.UI.Input
    import MyAppWeb.UI.Kbd
    import MyAppWeb.UI.Modal
    import MyAppWeb.UI.Progress
    import MyAppWeb.UI.Separator
    import MyAppWeb.UI.Skeleton
    import MyAppWeb.UI.Spinner
    import MyAppWeb.UI.Stat
    import MyAppWeb.UI.Table
    import MyAppWeb.UI.Tabs
    import MyAppWeb.UI.Toast
    import MyAppWeb.UI.Toggle
  end
end
```

If you want to use AvenUI directly from the dependency instead of your copied modules, `use AvenUI, :components` is also available.

### 4. Add the CSS

```css
/* assets/css/app.css */
@import "tailwindcss";
@import "./avenui.css";
```

No `tailwind.config.js` is needed with Tailwind v4.

### 5. Add the JS hooks

```js
// assets/js/app.js
import { AvenUIHooks } from "./hooks/aven_ui";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...AvenUIHooks, ...Hooks },
});
```

### 6. Render flash toasts in your root layout

```heex
<%!-- lib/my_app_web/components/layouts/root.html.heex --%>
<body>
  <%= @inner_content %>
  <.flash_group flash={@flash} />
</body>
```

---

## Project structure

```text
aven_ui/
├── mix.exs
├── lib/
│   ├── aven_ui.ex
│   └── aven_ui/
│       ├── data_table.ex
│       ├── helpers.ex
│       ├── components/
│       │   ├── accordion.ex
│       │   ├── alert.ex
│       │   ├── avatar.ex
│       │   ├── badge.ex
│       │   ├── button.ex
│       │   ├── card.ex
│       │   ├── code_block.ex
│       │   ├── combobox.ex
│       │   ├── data_table.ex
│       │   ├── date_picker.ex
│       │   ├── dropdown.ex
│       │   ├── empty_state.ex
│       │   ├── input.ex
│       │   ├── kbd.ex
│       │   ├── modal.ex
│       │   ├── progress.ex
│       │   ├── separator.ex
│       │   ├── skeleton.ex
│       │   ├── spinner.ex
│       │   ├── stat.ex
│       │   ├── table.ex
│       │   ├── tabs.ex
│       │   ├── toast.ex
│       │   └── toggle.ex
│       └── mix/tasks/
│           ├── add.ex
│           ├── list.ex
│           └── new.ex
├── assets/
│   ├── css/avenui.css
│   └── js/hooks/index.js
└── storybook/
```

---

## Component inventory

### Forms

- Input / Select
- Combobox
- Date Picker
- Toggle

### Actions and navigation

- Button
- Dropdown
- Tabs
- Accordion

### Data and layout

- Table
- Data Table
- Card
- Stat

### Feedback and overlays

- Alert
- Toast / Flash
- Modal

### Display and utility

- Avatar
- Badge
- Code Block
- Empty State
- Kbd
- Progress
- Separator
- Skeleton
- Spinner

---

## Examples

### Button

```heex
<.button>Deploy</.button>
<.button variant="secondary" size="sm">Cancel</.button>
<.button variant="danger" phx-click="delete" phx-value-id={@id}>Delete</.button>
<.button loading={@saving}>Saving...</.button>
```

Variants: `primary` `secondary` `ghost` `danger` `outline` `link`  
Sizes: `xs` `sm` `md` `lg` `xl`

### Input + Select

```heex
<.input field={@form[:email]} type="email" label="Email" hint="We'll never share this." />

<.input field={@form[:amount]} label="Amount">
  <:prefix>$</:prefix>
</.input>

<.select
  field={@form[:region]}
  label="Region"
  options={[{"Bangkok", "bangkok"}, {"Singapore", "singapore"}, {"Tokyo", "tokyo"}]}
  prompt="Choose..."
/>
```

### Combobox

```heex
<.combobox
  id="country"
  field={@form[:country]}
  label="Country"
  placeholder="Search countries..."
  options={[
    %{value: "th", label: "Thailand"},
    %{value: "sg", label: "Singapore"},
    %{value: "jp", label: "Japan"}
  ]}
/>

<.combobox
  id="user"
  name="user_id"
  label="User"
  placeholder="Search users..."
  options={@users}
  selected={@user_id}
  on_search="search_users"
/>
```

### Date Picker

```heex
<.date_picker
  id="birthday"
  name="birthday"
  label="Birthday"
  selected={@birthday}
  view_month={@dp_month}
  on_change="date_selected"
/>

<.date_picker
  id="booking"
  name="booking"
  label="Stay dates"
  mode="range"
  range_start={@check_in}
  range_end={@check_out}
  view_month={@dp_month}
  on_change="dates_selected"
/>
```

```elixir
def handle_event("date_selected", %{"date" => date}, socket) do
  {:noreply, assign(socket, :birthday, Date.from_iso8601!(date))}
end

def handle_event("dp_prev_month_birthday", _, socket) do
  {:noreply, update(socket, :dp_month, &Date.beginning_of_month(Date.add(&1, -1)))}
end

def handle_event("dp_next_month_birthday", _, socket) do
  {:noreply, update(socket, :dp_month, &Date.beginning_of_month(Date.add(&1, 32)))}
end
```

### Card

```heex
<.card>
  <:header>
    <.card_title>Server #3</.card_title>
    <.card_description>Last ping 2s ago</.card_description>
  </:header>
  <:body>
    <.progress value={72} label="CPU" show_value />
  </:body>
  <:footer>
    <.button size="sm">Restart</.button>
  </:footer>
</.card>
```

### Modal

```heex
<.button phx-click="open_modal">Open</.button>

<.modal :if={@show_modal} id="confirm-modal">
  <:title>Delete project?</:title>
  <:description>This cannot be undone.</:description>
  <p>All data will be permanently deleted.</p>
  <:footer>
    <.button variant="ghost" phx-click="close_modal">Cancel</.button>
    <.button variant="danger" phx-click="confirm_delete">Delete</.button>
  </:footer>
</.modal>
```

```elixir
def handle_event("open_modal", _, socket), do: {:noreply, assign(socket, show_modal: true)}
def handle_event("close_modal", _, socket), do: {:noreply, assign(socket, show_modal: false)}
```

### Dropdown

```heex
<.dropdown id="actions-menu">
  <:trigger>
    <.button variant="secondary" size="sm">Options <.dropdown_chevron /></.button>
  </:trigger>
  <.dropdown_label>Actions</.dropdown_label>
  <.dropdown_item phx-click="edit">Edit</.dropdown_item>
  <.dropdown_separator />
  <.dropdown_item variant="danger" phx-click="delete">Delete</.dropdown_item>
</.dropdown>
```

### Tabs

```heex
<.tabs active={@tab} patch="/dashboard" param="tab">
  <:tab id="overview">Overview</:tab>
  <:tab id="settings">Settings</:tab>
  <:panel id="overview"><.overview /></:panel>
  <:panel id="settings"><.settings_form /></:panel>
</.tabs>
```

Variants: `underline` `pills` `boxed`

### Table

```heex
<.table rows={@deployments} sort_field={@sort_by} sort_dir={@sort_dir}>
  <:col :let={row} label="Commit" field="sha" sortable>
    <code class="font-mono text-xs"><%= row.sha %></code>
  </:col>
  <:col :let={row} label="Status">
    <.badge variant={status_color(row.status)}><%= row.status %></.badge>
  </:col>
  <:action :let={row}>
    <.button size="xs" variant="ghost" phx-click="restart" phx-value-id={row.id}>
      Restart
    </.button>
  </:action>
</.table>

<.pagination page={@page} total_pages={@total_pages} phx-click="paginate" />
```

### Data Table

```heex
<.data_table
  id="users-table"
  rows={@rows}
  table={@table}
  title="Users"
  on_filter="dt_filter"
  on_sort="dt_sort"
  on_paginate="dt_paginate"
>
  <:filter>
    <.dt_search name="search" placeholder="Search users..." />
    <.dt_select
      name="status"
      prompt="All statuses"
      options={[{"Active", "active"}, {"Inactive", "inactive"}]}
    />
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
alias AvenUI.DataTable

def mount(_, _, socket) do
  {:ok, socket |> assign(:table, DataTable.new(per_page: 20)) |> load_rows()}
end

def handle_event("dt_filter", params, socket) do
  table =
    socket.assigns.table
    |> DataTable.set_filter(params)
    |> DataTable.reset_page()

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

### Toast / Flash

```heex
<.flash_group flash={@flash} />
```

```elixir
socket |> put_flash(:info, "Deployment complete!")
socket |> put_flash(:error, "Connection failed.")
```

### Accordion

```heex
<.accordion id="faq">
  <:item title="Is AvenUI free?">Yes. MIT licensed.</:item>
  <:item title="Does it support dark mode?" open>
    Yes — via CSS variables and Tailwind v4 theme tokens.
  </:item>
</.accordion>
```

### Avatar

```heex
<.avatar initials="KN" />
<.avatar initials="KN" size="lg" color="green" />
<.avatar src="https://..." alt="Khemmanat" />

<.avatar_group>
  <.avatar initials="KN" />
  <.avatar initials="AB" color="amber" />
  <.avatar initials="+3" color="gray" />
</.avatar_group>
```

### Stat

```heex
<div class="grid grid-cols-3 gap-4">
  <.stat label="Deploys today" value="24" change="+8" trend="up" />
  <.stat label="Avg response" value="142" suffix="ms" change="+12ms" trend="down" />
  <.stat label="Uptime (30d)" value="99.97" suffix="%" />
</div>
```

### Utility components

```heex
<.progress value={72} label="Storage" show_value color="blue" />
<.skeleton class="h-4 w-48" />
<.spinner size="lg" class="text-avn-purple" />
<.separator label="or continue with" />
<.kbd>⌘</.kbd><.kbd>K</.kbd>
<.empty_state title="No results" description="Try a different search." />
<.code_block lang="elixir" copyable>def hello, do: "world"</.code_block>
```

---

## JS Hooks

AvenUI exports 10 lightweight hooks:

| Hook               | Purpose                                 |
| ------------------ | --------------------------------------- |
| `Flash`            | Auto-dismiss with pause on hover        |
| `Dropdown`         | Keyboard nav, outside click close       |
| `Modal`            | Focus trap, Escape close, scroll lock   |
| `Tooltip`          | Position-aware tooltip                  |
| `AutoResize`       | Growing textarea                        |
| `CopyToClipboard`  | Clipboard API with feedback             |
| `InfiniteScroll`   | Load-more on sentinel visible           |
| `ScrollTop`        | Smooth scroll on LiveView patch         |
| `AvenUICombobox`   | Open, search, select, keyboard nav      |
| `AvenUIDatePicker` | Date-picker open/close and clear wiring |

```heex
<button phx-hook="Tooltip" id="info-btn" data-tooltip="More info">?</button>

<div phx-hook="Dropdown" id="my-menu">
  <button data-avn-dropdown-trigger>Open</button>
  <div data-avn-dropdown-menu hidden>
    <button data-avn-dropdown-item>Edit</button>
  </div>
</div>
```

---

## Storybook

Run the interactive component docs locally:

```bash
cd storybook
mix deps.get
mix phx.server
```

Then open `http://localhost:4000`.

---

## Roadmap

- Command palette
- Drawer / slideout panel
- Chart hooks
- Multi-select
- File upload

---

## License

MIT — free to use, modify, and distribute.
