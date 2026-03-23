defmodule StorybookWeb.ComponentLive do
  @moduledoc """
  AvenUI Storybook — live interactive component documentation.

  Mount at "/" in your router:

      live "/", StorybookWeb.ComponentLive
      live "/:component", StorybookWeb.ComponentLive
  """

  use Phoenix.LiveView

  # Import all AvenUI components
  use AvenUI, :components

  @components [
    %{id: "button",    label: "Button",     group: "Actions"},
    %{id: "badge",     label: "Badge",      group: "Display"},
    %{id: "alert",     label: "Alert",      group: "Feedback"},
    %{id: "toast",     label: "Toast",      group: "Feedback"},
    %{id: "modal",     label: "Modal",      group: "Overlay"},
    %{id: "dropdown",  label: "Dropdown",   group: "Overlay"},
    %{id: "card",      label: "Card",       group: "Layout"},
    %{id: "tabs",      label: "Tabs",       group: "Navigation"},
    %{id: "accordion", label: "Accordion",  group: "Layout"},
    %{id: "input",     label: "Input",      group: "Forms"},
    %{id: "toggle",    label: "Toggle",     group: "Forms"},
    %{id: "table",     label: "Table",      group: "Data"},
    %{id: "stat",      label: "Stat Card",  group: "Data"},
    %{id: "progress",  label: "Progress",   group: "Display"},
    %{id: "avatar",    label: "Avatar",     group: "Display"},
    %{id: "skeleton",  label: "Skeleton",   group: "Display"},
    %{id: "separator", label: "Separator",  group: "Utils"},
    %{id: "spinner",   label: "Spinner",    group: "Utils"},
    %{id: "kbd",       label: "Kbd",        group: "Utils"},
    %{id: "empty",     label: "Empty State", group: "Utils"},
    %{id: "code",      label: "Code Block", group: "Utils"},
  ]

  @impl true
  def mount(%{"component" => component}, _session, socket) do
    {:ok, assign(socket,
      active_component: component,
      preview_tab: "preview",
      show_modal: false,
      modal_size: "md",
      accordion_tab: "acc",
      nav_tab: "overview",
      dark_mode: false,
      components: @components
    )}
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      active_component: "button",
      preview_tab: "preview",
      show_modal: false,
      modal_size: "md",
      accordion_tab: "acc",
      nav_tab: "overview",
      dark_mode: false,
      components: @components
    )}
  end

  @impl true
  def handle_params(%{"component" => c}, _uri, socket) do
    {:noreply, assign(socket, active_component: c)}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("select_component", %{"id" => id}, socket) do
    {:noreply, push_patch(socket, to: "/#{id}")}
  end

  def handle_event("preview_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, preview_tab: tab)}
  end

  def handle_event("open_modal",  %{"size" => size}, socket) do
    {:noreply, assign(socket, show_modal: true, modal_size: size)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, nav_tab: tab)}
  end

  def handle_event("toggle_dark", _, socket) do
    {:noreply, assign(socket, dark_mode: !socket.assigns.dark_mode)}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <div class={["flex h-screen bg-avn-background overflow-hidden", if(@dark_mode, do: "dark")]}>

      <%# ── Sidebar ─────────────────────────────────────────────── %>
      <aside class="w-56 shrink-0 border-r border-avn-border flex flex-col">
        <%# Logo %>
        <div class="flex items-center gap-2.5 px-4 py-4 border-b border-avn-border">
          <div class="h-7 w-7 rounded-lg bg-gradient-to-br from-violet-500 to-violet-700 flex items-center justify-center text-white text-xs font-bold">
            E
          </div>
          <span class="font-medium text-sm text-avn-foreground">AvenUI</span>
          <span class="ml-auto text-xs text-avn-muted-foreground font-mono">v0.1</span>
        </div>

        <%# Dark mode toggle %>
        <div class="px-4 py-3 border-b border-avn-border">
          <.toggle
            name="dark_mode"
            checked={@dark_mode}
            label="Dark mode"
            phx-change="toggle_dark"
          />
        </div>

        <%# Nav groups %>
        <nav class="flex-1 overflow-y-auto py-2">
          <%= for {group, items} <- grouped_components(@components) do %>
            <div class="mb-1">
              <p class="px-4 py-1 text-[10px] font-semibold text-avn-muted-foreground uppercase tracking-widest">
                <%= group %>
              </p>
              <%= for item <- items do %>
                <button
                  type="button"
                  phx-click="select_component"
                  phx-value-id={item.id}
                  class={[
                    "w-full text-left px-4 py-1.5 text-sm rounded-md transition-colors mx-1 w-[calc(100%-8px)]",
                    if(item.id == @active_component,
                      do: "bg-violet-50 text-violet-700 font-medium dark:bg-violet-950/40 dark:text-violet-300",
                      else: "text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted"
                    )
                  ]}
                >
                  <%= item.label %>
                </button>
              <% end %>
            </div>
          <% end %>
        </nav>

        <div class="px-4 py-3 border-t border-avn-border">
          <a
            href="https://github.com/khemmanat/aven_ui"
            target="_blank"
            class="flex items-center gap-2 text-xs text-avn-muted-foreground hover:text-avn-foreground transition-colors"
          >
            <svg class="h-4 w-4" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
            </svg>
            GitHub
          </a>
        </div>
      </aside>

      <%# ── Main content ──────────────────────────────────────────── %>
      <main class="flex-1 overflow-y-auto">
        <div class="max-w-4xl mx-auto px-8 py-8">

          <%# Header %>
          <div class="mb-6">
            <h1 class="text-xl font-medium text-avn-foreground capitalize">
              <%= current_label(@components, @active_component) %>
            </h1>
            <p class="text-sm text-avn-muted-foreground mt-0.5">
              <%= component_description(@active_component) %>
            </p>
          </div>

          <%# Preview / Code tabs %>
          <.tabs active={@preview_tab} on_change="preview_tab" variant="pills" class="mb-6">
            <:tab id="preview">Preview</:tab>
            <:tab id="code">Code</:tab>
            <:tab id="props">Props</:tab>
          </.tabs>

          <%# Preview panel %>
          <%= if @preview_tab == "preview" do %>
            <div class="rounded-avn-xl border border-avn-border overflow-hidden">
              <div class="flex items-center justify-between px-4 py-2 bg-avn-muted border-b border-avn-border">
                <span class="text-xs text-avn-muted-foreground font-mono">Preview</span>
                <div class="flex gap-1.5">
                  <div class="h-2.5 w-2.5 rounded-full bg-red-400" />
                  <div class="h-2.5 w-2.5 rounded-full bg-amber-400" />
                  <div class="h-2.5 w-2.5 rounded-full bg-green-400" />
                </div>
              </div>
              <div class="p-8 bg-avn-background min-h-[240px] flex items-start justify-center">
                <%= render_preview(assigns) %>
              </div>
            </div>
          <% end %>

          <%# Code panel %>
          <%= if @preview_tab == "code" do %>
            <.code_block lang="heex" copyable>
              <%= component_code(@active_component) %>
            </.code_block>
          <% end %>

          <%# Props panel %>
          <%= if @preview_tab == "props" do %>
            <.card>
              <:body>
                <.table rows={component_props(@active_component)}>
                  <:col :let={r} label="Attr">
                    <code class="text-xs font-mono text-violet-600 dark:text-violet-400"><%= r.name %></code>
                  </:col>
                  <:col :let={r} label="Type"><%= r.type %></:col>
                  <:col :let={r} label="Default">
                    <code class="text-xs font-mono text-avn-muted-foreground"><%= r.default %></code>
                  </:col>
                  <:col :let={r} label="Description"><%= r.description %></:col>
                </.table>
              </:body>
            </.card>
          <% end %>

        </div>
      </main>
    </div>

    <%# Modal for demo %>
    <.modal
      :if={@show_modal}
      id="demo-modal"
      size={@modal_size}
      on_close="close_modal"
    >
      <:title>Example modal</:title>
      <:description>This is the modal description slot.</:description>
      <p class="text-sm text-avn-muted-foreground leading-relaxed">
        Modal body content goes here. You can put forms, data, confirmations,
        or any content inside this scrollable area.
      </p>
      <:footer>
        <.button variant="ghost" phx-click="close_modal">Cancel</.button>
        <.button variant="primary" phx-click="close_modal">Confirm</.button>
      </:footer>
    </.modal>
    """
  end

  # ── Preview renderers ──────────────────────────────────────────────

  defp render_preview(%{active_component: "button"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3 items-center">
      <.button>Primary</.button>
      <.button variant="secondary">Secondary</.button>
      <.button variant="ghost">Ghost</.button>
      <.button variant="danger">Danger</.button>
      <.button loading={true}>Loading</.button>
      <.button disabled>Disabled</.button>
    </div>
    """
  end

  defp render_preview(%{active_component: "badge"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-2 items-center">
      <.badge>Default</.badge>
      <.badge variant="primary"><.badge_dot />Active</.badge>
      <.badge variant="success"><.badge_dot />Online</.badge>
      <.badge variant="warning">Pending</.badge>
      <.badge variant="danger">Expired</.badge>
      <.badge variant="info">Info</.badge>
    </div>
    """
  end

  defp render_preview(%{active_component: "alert"} = assigns) do
    ~H"""
    <div class="w-full max-w-lg space-y-3">
      <.alert variant="info"    title="Migration required">Run mix ecto.migrate before deploying.</.alert>
      <.alert variant="success" title="Deployment complete">Version 2.4.1 is now live.</.alert>
      <.alert variant="warning" title="High memory usage">Node #3 is at 87%.</.alert>
      <.alert variant="danger"  title="Connection failed" dismissible phx-click="">Cannot reach Postgres.</.alert>
    </div>
    """
  end

  defp render_preview(%{active_component: "toast"} = assigns) do
    ~H"""
    <div class="w-full max-w-sm space-y-3">
      <.toast id="t-success" variant="success" title="Saved!" duration={0}>Changes saved successfully.</.toast>
      <.toast id="t-error"   variant="error"   title="Error"   duration={0}>Could not connect to the server.</.toast>
      <.toast id="t-warning" variant="warning" title="Warning" duration={0}>Your session expires in 5 minutes.</.toast>
    </div>
    """
  end

  defp render_preview(%{active_component: "modal"} = assigns) do
    ~H"""
    <div class="flex flex-wrap gap-3">
      <%= for size <- ~w(sm md lg) do %>
        <.button variant="secondary" phx-click="open_modal" phx-value-size={size}>
          Open <%= size %> modal
        </.button>
      <% end %>
    </div>
    """
  end

  defp render_preview(%{active_component: "dropdown"} = assigns) do
    ~H"""
    <.dropdown id="demo-dropdown">
      <:trigger>
        <.button variant="secondary">
          Options <.dropdown_chevron />
        </.button>
      </:trigger>
      <.dropdown_label>Actions</.dropdown_label>
      <.dropdown_item>Edit</.dropdown_item>
      <.dropdown_item>Duplicate</.dropdown_item>
      <.dropdown_separator />
      <.dropdown_item variant="danger">Delete</.dropdown_item>
    </.dropdown>
    """
  end

  defp render_preview(%{active_component: "card"} = assigns) do
    ~H"""
    <.card class="w-80">
      <:header>
        <div class="flex items-center justify-between">
          <.card_title>Server #3</.card_title>
          <.badge variant="success"><.badge_dot />Healthy</.badge>
        </div>
        <.card_description>Bangkok · Last ping 2s ago</.card_description>
      </:header>
      <:body>
        <div class="space-y-3">
          <.progress value={14}  label="CPU"    show_value />
          <.progress value={61}  label="Memory" show_value color="blue" />
          <.progress value={38}  label="Disk"   show_value color="green" />
        </div>
      </:body>
      <:footer>
        <div class="flex justify-end gap-2">
          <.button size="sm" variant="ghost">Logs</.button>
          <.button size="sm">Restart</.button>
        </div>
      </:footer>
    </.card>
    """
  end

  defp render_preview(%{active_component: "tabs", nav_tab: nav_tab} = assigns) do
    ~H"""
    <div class="w-full max-w-lg space-y-6">
      <.tabs active={@nav_tab} on_change="switch_tab" variant="underline">
        <:tab id="overview">Overview</:tab>
        <:tab id="deployments" badge="3">Deployments</:tab>
        <:tab id="settings">Settings</:tab>
        <:panel id="overview"><p class="py-4 text-sm text-avn-muted-foreground">Overview content here.</p></:panel>
        <:panel id="deployments"><p class="py-4 text-sm text-avn-muted-foreground">3 recent deployments.</p></:panel>
        <:panel id="settings"><p class="py-4 text-sm text-avn-muted-foreground">Settings panel here.</p></:panel>
      </.tabs>
      <.tabs active={@nav_tab} on_change="switch_tab" variant="pills">
        <:tab id="overview">Overview</:tab>
        <:tab id="deployments">Deployments</:tab>
        <:tab id="settings">Settings</:tab>
      </.tabs>
    </div>
    """
  end

  defp render_preview(%{active_component: "accordion"} = assigns) do
    ~H"""
    <div class="w-full max-w-lg">
      <.accordion id="demo-acc">
        <:item title="What is AvenUI?">
          A free, MIT-licensed UI component library for Phoenix LiveView. No paywalls.
        </:item>
        <:item title="Does it support dark mode?" open>
          Yes — via CSS variables. No flash of unstyled content, no Tailwind class toggling.
        </:item>
        <:item title="Can I customize components?">
          Use <code>mix aven_ui.add</code> to copy components into your project.
          You own the code and can edit it freely.
        </:item>
      </.accordion>
    </div>
    """
  end

  defp render_preview(%{active_component: "input"} = assigns) do
    ~H"""
    <div class="w-full max-w-sm space-y-4">
      <.input type="text"  name="name"  label="Full name"  placeholder="Khemmanat N." />
      <.input type="email" name="email" label="Email" hint="We'll never share your email.">
        <:prefix>@</:prefix>
      </.input>
      <.select name="region" label="Region" options={["Bangkok", "Singapore", "Tokyo"]} prompt="Choose region…" />
    </div>
    """
  end

  defp render_preview(%{active_component: "toggle"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.toggle name="a" checked label="Dark mode" hint="Switch the theme" />
      <.toggle name="b" checked={false} label="Notifications" />
      <.toggle name="c" checked size="lg" label="Auto-deploy on merge" />
    </div>
    """
  end

  defp render_preview(%{active_component: "table"} = assigns) do
    rows = [
      %{sha: "3f2a9c1", branch: "main",      user: "KN", status: "success"},
      %{sha: "a7c1e3f", branch: "feat/auth", user: "AB", status: "warning"},
      %{sha: "9d4b820", branch: "fix/csp",   user: "TH", status: "danger"},
    ]
    assigns = assign(assigns, :rows, rows)
    ~H"""
    <div class="w-full">
      <.table rows={@rows}>
        <:col :let={r} label="Commit">
          <code class="text-xs font-mono"><%= r.sha %></code>
        </:col>
        <:col :let={r} label="Branch"><%= r.branch %></:col>
        <:col :let={r} label="Status">
          <.badge variant={r.status}><.badge_dot /><%= r.status %></.badge>
        </:col>
      </.table>
    </div>
    """
  end

  defp render_preview(%{active_component: "stat"} = assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-4 w-full max-w-2xl">
      <.stat label="Deploys today"  value="24"     change="+8"    trend="up" />
      <.stat label="Avg response"   value="142"    suffix="ms"    change="+12ms" trend="down" />
      <.stat label="Uptime (30d)"   value="99.97"  suffix="%"     change="—" trend="neutral" />
    </div>
    """
  end

  defp render_preview(%{active_component: "progress"} = assigns) do
    ~H"""
    <div class="w-full max-w-md space-y-4">
      <.progress value={72}  label="Storage"    show_value />
      <.progress value={45}  label="Deployment" show_value color="blue" size="lg" />
      <.progress value={91}  label="Tasks"      show_value color="green" size="sm" />
      <.progress value={100} label="Complete"   show_value color="green" />
    </div>
    """
  end

  defp render_preview(%{active_component: "avatar"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="flex items-end gap-3">
        <.avatar initials="KN" size="xs" />
        <.avatar initials="KN" size="sm" />
        <.avatar initials="KN" />
        <.avatar initials="KN" size="lg" color="green" />
        <.avatar initials="KN" size="xl" color="amber" />
      </div>
      <.avatar_group>
        <.avatar initials="KN" />
        <.avatar initials="AB" color="amber" />
        <.avatar initials="TH" color="green" />
        <.avatar initials="+3" color="gray" />
      </.avatar_group>
    </div>
    """
  end

  defp render_preview(%{active_component: "skeleton"} = assigns) do
    ~H"""
    <.card class="w-72">
      <:body>
        <div class="flex gap-3 items-start">
          <.skeleton class="h-10 w-10 rounded-full shrink-0" />
          <div class="flex-1 space-y-2 pt-1">
            <.skeleton class="h-3 w-3/5" />
            <.skeleton class="h-3 w-full" />
            <.skeleton class="h-3 w-4/5" />
          </div>
        </div>
        <div class="mt-4 space-y-2">
          <.skeleton class="h-8 w-full rounded-elx" />
          <.skeleton class="h-8 w-full rounded-elx" />
        </div>
      </:body>
    </.card>
    """
  end

  defp render_preview(%{active_component: "separator"} = assigns) do
    ~H"""
    <div class="w-full max-w-xs space-y-4">
      <.separator />
      <.separator label="or continue with" />
      <div class="flex items-center gap-4 h-8">
        <span class="text-sm text-avn-muted-foreground">Left</span>
        <.separator orientation="vertical" class="h-full" />
        <span class="text-sm text-avn-muted-foreground">Right</span>
      </div>
    </div>
    """
  end

  defp render_preview(%{active_component: "spinner"} = assigns) do
    ~H"""
    <div class="flex items-end gap-4">
      <.spinner size="xs" />
      <.spinner size="sm" />
      <.spinner size="md" />
      <.spinner size="lg" class="text-violet-600" />
      <.spinner size="xl" class="text-violet-400" />
    </div>
    """
  end

  defp render_preview(%{active_component: "kbd"} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3 text-sm text-avn-foreground">
      <span>Save: <.kbd>⌘</.kbd> <.kbd>S</.kbd></span>
      <span>Search: <.kbd>⌘</.kbd> <.kbd>K</.kbd></span>
      <span>Close: <.kbd>Escape</.kbd></span>
    </div>
    """
  end

  defp render_preview(%{active_component: "empty"} = assigns) do
    ~H"""
    <.empty_state title="No deployments yet" description="Push a commit to trigger your first deploy.">
      <.button variant="secondary" size="sm">Read the docs</.button>
    </.empty_state>
    """
  end

  defp render_preview(%{active_component: "code"} = assigns) do
    ~H"""
    <div class="w-full max-w-lg">
      <.code_block lang="elixir" copyable>
def hello, do: "world"

def greet(name) do
  "Hello, #{name}!"
end
      </.code_block>
    </div>
    """
  end

  defp render_preview(assigns) do
    ~H"""
    <.empty_state title="Preview coming soon" description="This component preview is being built." />
    """
  end

  # ── Helpers ──────────────────────────────────────────────────────────

  defp grouped_components(components) do
    components
    |> Enum.group_by(& &1.group)
    |> Enum.sort_by(fn {g, _} -> group_order(g) end)
  end

  defp group_order(g) do
    %{"Actions" => 0, "Display" => 1, "Feedback" => 2,
      "Overlay" => 3, "Layout" => 4, "Navigation" => 5,
      "Forms" => 6, "Data" => 7, "Utils" => 8}[g] || 99
  end

  defp current_label(components, id) do
    Enum.find(components, %{label: id}, & &1.id == id).label
  end

  defp component_description(id) do
    %{
      "button"    => "Trigger actions with clear visual feedback. 6 variants, 5 sizes, loading state.",
      "badge"     => "Status labels and count indicators. 7 variants with optional dot indicator.",
      "alert"     => "Inline feedback banners for info, success, warning, and error states.",
      "toast"     => "Auto-dismissing notifications. Works with Phoenix Flash or PubSub.",
      "modal"     => "Dialog overlays with focus trap, scroll lock, and Escape-to-close.",
      "dropdown"  => "Accessible action menus with keyboard navigation, groups, and dividers.",
      "card"      => "Content containers with header, body, and footer slot composition.",
      "tabs"      => "Navigate between content sections. Underline, pills, and boxed variants.",
      "accordion" => "Collapsible content panels using pure LiveView JS — no hooks needed.",
      "input"     => "Form inputs with label, hint, error, prefix/suffix. Phoenix form-native.",
      "toggle"    => "Boolean switch input. Works with phx-change and Phoenix form fields.",
      "table"     => "Sortable data table with LiveView stream support and pagination.",
      "stat"      => "KPI metric cards with value, change, and trend direction.",
      "progress"  => "Progress bar with label, value display, 5 colors, and 5 sizes.",
      "avatar"    => "User initials or image avatars with group stacking.",
      "skeleton"  => "Loading placeholder shimmer for async content.",
      "separator" => "Horizontal/vertical dividers with optional text label.",
      "spinner"   => "Animated loading indicator. 5 sizes, inherits color.",
      "kbd"       => "Keyboard shortcut display with native keyboard styling.",
      "empty"     => "Empty state with icon, title, description, and action slot.",
      "code"      => "Syntax-highlighted code block with language label and copy button.",
    }[id] || "Component documentation."
  end

  defp component_code(id) do
    codes = %{
      "button" => ~s"""
<.button>Primary</.button>

<.button variant="secondary" size="sm">Cancel</.button>

<.button variant="danger" phx-click="delete" phx-value-id={@item.id}>
  Delete
</.button>

<.button loading={@saving}>
  Saving…
</.button>
""",
      "badge" => ~s"""
<.badge>Default</.badge>

<.badge variant="success">
  <.badge_dot /> Online
</.badge>

<.badge variant="danger" size="lg">Expired</.badge>
""",
      "alert" => ~s"""
<.alert variant="success" title="Deployment complete">
  Version 2.4.1 is live.
</.alert>

<.alert variant="warning" title="High memory" dismissible phx-click="dismiss">
  Node #3 is at 87%.
</.alert>
""",
      "modal" => ~s"""
<%# Trigger %>
<.button phx-click="open_modal">Open modal</.button>

<%# In template %>
<.modal :if={@show_modal} id="confirm-modal" on_close="close_modal">
  <:title>Delete project?</:title>
  <:description>This cannot be undone.</:description>

  <p>All data will be permanently deleted.</p>

  <:footer>
    <.button variant="ghost" phx-click="close_modal">Cancel</.button>
    <.button variant="danger" phx-click="confirm_delete">Delete</.button>
  </:footer>
</.modal>

<%# LiveView events %>
def handle_event("open_modal",  _, socket),
  do: {:noreply, assign(socket, show_modal: true)}

def handle_event("close_modal", _, socket),
  do: {:noreply, assign(socket, show_modal: false)}
""",
      "tabs" => ~s"""
<%# With content panels and URL sync %>
<.tabs active={@tab} patch="/dashboard" param="tab">
  <:tab id="overview">Overview</:tab>
  <:tab id="settings">Settings</:tab>
  <:panel id="overview"><.overview_content /></:panel>
  <:panel id="settings"><.settings_form /></:panel>
</.tabs>

<%# Pills variant %>
<.tabs active={@tab} on_change="switch_tab" variant="pills">
  <:tab id="day">Day</:tab>
  <:tab id="week">Week</:tab>
  <:tab id="month">Month</:tab>
</.tabs>
""",
      "table" => ~s"""
<.table rows={@deployments} sort_field={@sort_by} sort_dir={@sort_dir}>
  <:col :let={row} label="Commit" field="sha" sortable>
    <code class="font-mono text-xs"><%= row.sha %></code>
  </:col>
  <:col :let={row} label="Branch"><%= row.branch %></:col>
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
"""
    }
    Map.get(codes, id, "<%# See documentation for #{id} component %>")
  end

  defp component_props(id) do
    props = %{
      "button" => [
        %{name: "variant", type: "string", default: "primary",   description: "primary | secondary | ghost | danger | outline | link"},
        %{name: "size",    type: "string", default: "md",        description: "xs | sm | md | lg | xl"},
        %{name: "loading", type: "boolean",default: "false",     description: "Shows spinner and disables button"},
        %{name: "disabled",type: "boolean",default: "false",     description: "Disables the button"},
        %{name: "type",    type: "string", default: "button",    description: "button | submit | reset"},
      ],
      "badge" => [
        %{name: "variant", type: "string", default: "default",   description: "default | primary | success | warning | danger | info | outline"},
        %{name: "size",    type: "string", default: "md",        description: "sm | md | lg"},
      ],
      "alert" => [
        %{name: "variant",     type: "string",  default: "info",  description: "info | success | warning | danger"},
        %{name: "title",       type: "string",  default: "nil",   description: "Alert title (or use :title slot)"},
        %{name: "dismissible", type: "boolean", default: "false", description: "Show dismiss button"},
      ],
      "tabs" => [
        %{name: "active",    type: "string", default: "—",         description: "ID of the active tab"},
        %{name: "variant",   type: "string", default: "underline", description: "underline | pills | boxed"},
        %{name: "on_change", type: "string", default: "nil",       description: "phx event name on tab click"},
        %{name: "patch",     type: "string", default: "nil",       description: "URL prefix for patch navigation"},
        %{name: "param",     type: "string", default: "tab",       description: "Query param name when using patch"},
        %{name: "size",      type: "string", default: "md",        description: "sm | md | lg"},
      ],
    }
    Map.get(props, id, [
      %{name: "class", type: "string", default: "nil", description: "Additional CSS classes"}
    ])
  end
end
