# AvenUI

A free, open-source UI component library for **Phoenix LiveView** — the missing shadcn/ui for the Elixir ecosystem.

> **Free alternative to Petal.** MIT licensed. You own your components.

---

## Why AvenUI?

- **Zero JS by default** — every component works with pure LiveView server rendering
- **shadcn-style installer** — `mix aven_ui.add button badge` copies code into your project so you own it
- **Full dark mode** — CSS variable tokens, no Tailwind class flicker
- **LiveView streams** — Table and lists support `phx-update="stream"` out of the box
- **Form-native** — Input and Select integrate with `Phoenix.HTML.FormField` + Ecto changesets
- **Accessible** — ARIA roles, keyboard navigation, focus management built in
- **Tailwind v3 + v4** compatible

---

## Installation

### 1. Add dep

```elixir
# mix.exs
def deps do
  [
    {:aven_ui, "~> 0.1", github: "khemmanat/aven_ui"}
  ]
end
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

Components are copied into `lib/my_app_web/components/ui/` with the namespace
rewritten to `MyAppWeb.UI.*`. You own the code.

### 3. Import in web.ex

```elixir
# lib/my_app_web.ex
defp html_helpers do
  quote do
    use AvenUI, :components
    # or cherry-pick:
    # import MyAppWeb.UI.Button
    # import MyAppWeb.UI.Badge
  end
end
```

### 4. Add CSS

```css
/* assets/css/app.css */
@import "./avenui.css";
```

### 5. Add JS hooks

```js
// assets/js/app.js
import { AvenUIHooks } from "./hooks/aven_ui";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...AvenUIHooks, ...YourHooks },
});
```

### 6. Add Tailwind preset

```js
// assets/tailwind.config.js
const avenUIPreset = require("../../deps/aven_ui/assets/tailwind.config.js");

module.exports = {
  presets: [avenUIPreset],
  content: ["./lib/**/*.{ex,heex}", "./assets/js/**/*.js"],
};
```

### 7. Add flash toasts to root layout

```heex
<%!-- lib/my_app_web/components/layouts/root.html.heex --%>
<body>
  <%= @inner_content %>
  <.flash_group flash={@flash} />
</body>
```

---

## Project structure

```
aven_ui/
├── mix.exs
├── lib/
│   ├── aven_ui.ex                        ← use AvenUI, :components macro
│   └── aven_ui/
│       ├── helpers.ex                    ← shared classes/1 utility
│       ├── components/
│       │   ├── accordion.ex
│       │   ├── alert.ex
│       │   ├── avatar.ex
│       │   ├── badge.ex
│       │   ├── button.ex
│       │   ├── card.ex
│       │   ├── code_block.ex
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
│           └── add.ex                    ← mix aven_ui.add
├── assets/
│   ├── css/avenui.css                    ← --avn- CSS design tokens
│   ├── js/hooks/index.js                 ← AvenUIHooks
│   └── tailwind.config.js
└── storybook/                            ← live component docs (Phoenix app)
```

---

## Components

### Button

```heex
<.button>Deploy</.button>
<.button variant="secondary" size="sm">Cancel</.button>
<.button variant="danger" phx-click="delete" phx-value-id={@id}>Delete</.button>
<.button loading={@saving}>Saving…</.button>
```

**Variants:** `primary` `secondary` `ghost` `danger` `outline` `link`  
**Sizes:** `xs` `sm` `md` `lg` `xl`

---

### Badge

```heex
<.badge>Default</.badge>
<.badge variant="success"><.badge_dot /> Online</.badge>
<.badge variant="danger">Expired</.badge>
```

**Variants:** `default` `primary` `success` `warning` `danger` `info` `outline`

---

### Alert

```heex
<.alert variant="success" title="Deployed!">Version 2.4.1 is live.</.alert>
<.alert variant="warning" title="High memory" dismissible phx-click="dismiss">
  Node #3 is at 87%.
</.alert>
```

---

### Input + Select

```heex
<.input field={@form[:email]} type="email" label="Email" hint="We'll never share this." />

<.input field={@form[:amount]} label="Amount">
  <:prefix>฿</:prefix>
</.input>

<.select field={@form[:region]} label="Region"
  options={["Bangkok", "Singapore", "Tokyo"]} prompt="Choose…" />
```

---

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

---

### Modal

```heex
<.button phx-click="open_modal">Open</.button>

<.modal :if={@show_modal} id="confirm-modal" on_close="close_modal">
  <:title>Delete project?</:title>
  <:description>This cannot be undone.</:description>
  <p>All data will be permanently deleted.</p>
  <:footer>
    <.button variant="ghost" phx-click="close_modal">Cancel</.button>
    <.button variant="danger" phx-click="confirm_delete">Delete</.button>
  </:footer>
</.modal>
```

In LiveView:

```elixir
def handle_event("open_modal",  _, socket), do: {:noreply, assign(socket, show_modal: true)}
def handle_event("close_modal", _, socket), do: {:noreply, assign(socket, show_modal: false)}
```

---

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

---

### Tabs

```heex
<.tabs active={@tab} patch="/dashboard" param="tab">
  <:tab id="overview">Overview</:tab>
  <:tab id="settings">Settings</:tab>
  <:panel id="overview"><.overview /></:panel>
  <:panel id="settings"><.settings_form /></:panel>
</.tabs>
```

**Variants:** `underline` `pills` `boxed`

---

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

---

### Toast / Flash

```heex
<%!-- In root.html.heex — renders all @flash messages as toasts --%>
<.flash_group flash={@flash} />
```

From LiveView:

```elixir
socket |> put_flash(:success, "Deployment complete!")
socket |> put_flash(:error,   "Connection failed.")
```

---

### Accordion

```heex
<.accordion id="faq">
  <:item title="Is AvenUI free?">Yes. MIT licensed.</:item>
  <:item title="Does it support dark mode?" open>
    Yes — via CSS variables, no Tailwind class flicker.
  </:item>
</.accordion>
```

---

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

---

### Stat

```heex
<div class="grid grid-cols-3 gap-4">
  <.stat label="Deploys today" value="24"    change="+8"    trend="up" />
  <.stat label="Avg response"  value="142"   suffix="ms"    change="+12ms" trend="down" />
  <.stat label="Uptime (30d)"  value="99.97" suffix="%" />
</div>
```

---

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

| Hook              | Purpose                           |
| ----------------- | --------------------------------- |
| `Dropdown`        | Keyboard nav, outside-click close |
| `Modal`           | Focus trap, scroll lock, Escape   |
| `Tooltip`         | Position-aware tooltip            |
| `Flash`           | Auto-dismiss with pause-on-hover  |
| `AutoResize`      | Growing textarea                  |
| `CopyToClipboard` | Clipboard API with feedback       |
| `InfiniteScroll`  | Load-more on sentinel visible     |
| `ScrollTop`       | Smooth scroll on LiveView patch   |

```heex
<%!-- Tooltip usage --%>
<button phx-hook="Tooltip" id="info-btn" data-tooltip="More info">?</button>

<%!-- Dropdown usage --%>
<div phx-hook="Dropdown" id="my-menu">
  <button data-avn-dropdown-trigger>Open</button>
  <div data-avn-dropdown-menu hidden>
    <button data-avn-dropdown-item>Edit</button>
  </div>
</div>
```

---

## Storybook

Run the interactive component doc site locally:

```bash
cd storybook
mix deps.get
mix phx.server
# Open http://localhost:4000
```

---

## Roadmap

- [ ] Command Palette / Combobox
- [ ] Drawer / Slideout panel
- [ ] Date Picker
- [ ] Chart hooks (VegaLite + Chart.js)
- [ ] Multi-select
- [ ] File upload
- [ ] Publish to Hex.pm

---

## License

MIT — free to use, modify, and distribute.
