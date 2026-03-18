defmodule AvenUI.Components.Tabs do
  @moduledoc """
  Tabs component with two visual styles and optional LiveView URL-sync.

  ## Variants

  - `underline` — classic bottom-border tabs (default, like GitHub)
  - `pills`     — rounded pill buttons (like Notion or shadcn)
  - `boxed`     — segmented control style (like macOS)

  ## Modes

  **LiveView event mode** (default) — tab changes push a `switch_tab` event:

      <.tabs active={@active_tab} on_change="switch_tab">
        <:tab id="overview">Overview</:tab>
        <:tab id="deployments">Deployments</:tab>
        <:tab id="settings">Settings</:tab>
      </.tabs>

      def handle_event("switch_tab", %{"tab" => tab}, socket) do
        {:noreply, assign(socket, active_tab: tab)}
      end

  **URL patch mode** — tab changes patch the current URL:

      <.tabs active={@active_tab} patch="/projects/:id" param="tab">
        <:tab id="overview">Overview</:tab>
        <:tab id="settings">Settings</:tab>
      </.tabs>

      # In mount/handle_params:
      def handle_params(%{"tab" => tab}, _uri, socket) do
        {:noreply, assign(socket, active_tab: tab || "overview")}
      end

  **Tabs with content panels** — pass panels via inner_block:

      <.tabs active={@tab} on_change="switch_tab">
        <:tab id="code">Code</:tab>
        <:tab id="preview">Preview</:tab>
        <:tab id="settings">Settings</:tab>
        <:panel id="code"><pre><code>...</code></pre></:panel>
        <:panel id="preview"><.live_preview /></:panel>
        <:panel id="settings"><.settings_form /></:panel>
      </.tabs>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :active,    :string,  required: true, doc: "ID of the currently active tab"
  attr :variant,   :string,  default: "underline", values: ~w(underline pills boxed)
  attr :on_change, :string,  default: nil, doc: "phx event name on tab click"
  attr :patch,     :string,  default: nil, doc: "URL prefix for patch navigation"
  attr :param,     :string,  default: "tab", doc: "Query param name when using patch"
  attr :size,      :string,  default: "md", values: ~w(sm md lg)
  attr :class,     :string,  default: nil

  slot :tab, required: true do
    attr :id,    :string, required: true
    attr :badge, :string, doc: "Optional count badge shown next to tab label"
    attr :icon,  :string, doc: "Optional SVG path for an icon"
  end

  slot :panel, doc: "Content panel — rendered when its id matches active" do
    attr :id, :string, required: true
  end

  def tabs(assigns) do
    ~H"""
    <div class={classes(["w-full", @class])}>
      <%# Tab bar %>
      <div
        role="tablist"
        class={tablist_class(@variant)}
        aria-label="Tabs"
      >
        <%= for tab <- @tab do %>
          <button
            type="button"
            role="tab"
            id={"tab-#{tab.id}"}
            aria-selected={tab.id == @active}
            aria-controls={"panel-#{tab.id}"}
            phx-click={tab_click(tab.id, @on_change, @patch, @param)}
            class={classes([
              tab_class(@variant, @size),
              if(tab.id == @active, do: active_tab_class(@variant), else: inactive_tab_class(@variant))
            ])}
          >
            <%= render_slot(tab) %>
            <%= if tab[:badge] do %>
              <span class={badge_class(@variant, tab.id == @active)}>
                <%= tab.badge %>
              </span>
            <% end %>
          </button>
        <% end %>
      </div>

      <%# Panels %>
      <%= if @panel != [] do %>
        <%= for panel <- @panel do %>
          <div
            id={"panel-#{panel.id}"}
            role="tabpanel"
            aria-labelledby={"tab-#{panel.id}"}
            hidden={panel.id != @active}
            class="focus:outline-none"
            tabindex="0"
          >
            <%= render_slot(panel) %>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  # ── Private Helpers ──────────────────────────────────────────────────

  defp tab_click(id, on_change, nil, _param) when on_change != nil do
    JS.push(on_change, value: %{tab: id})
  end

  defp tab_click(id, _on_change, patch, param) when patch != nil do
    JS.patch("#{patch}?#{param}=#{id}")
  end

  defp tab_click(id, nil, nil, _) do
    # No-op — parent must handle via phx-value or similar
    JS.push("switch_tab", value: %{tab: id})
  end

  defp tablist_class("underline") do
    "flex gap-0 border-b border-avn-border"
  end
  defp tablist_class("pills") do
    "flex gap-1 p-1 bg-avn-muted rounded-avn-lg"
  end
  defp tablist_class("boxed") do
    "inline-flex gap-0 border border-avn-border rounded-elx overflow-hidden bg-avn-muted"
  end

  defp tab_class("underline", size) do
    base = "inline-flex items-center gap-2 font-medium whitespace-nowrap transition-colors duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple focus-visible:ring-inset border-b-2 -mb-px"
    size_pad = case size do
      "sm" -> "px-3 py-2 text-xs"
      "lg" -> "px-5 py-3 text-base"
      _    -> "px-4 py-2.5 text-sm"
    end
    "#{base} #{size_pad}"
  end
  defp tab_class("pills", size) do
    base = "inline-flex items-center gap-2 font-medium whitespace-nowrap rounded-elx transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple"
    size_pad = case size do
      "sm" -> "px-3 py-1.5 text-xs"
      "lg" -> "px-5 py-2.5 text-base"
      _    -> "px-4 py-2 text-sm"
    end
    "#{base} #{size_pad}"
  end
  defp tab_class("boxed", size) do
    base = "inline-flex items-center gap-2 font-medium whitespace-nowrap transition-all duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple focus-visible:ring-inset border-r border-avn-border last:border-r-0"
    size_pad = case size do
      "sm" -> "px-3 py-1.5 text-xs"
      "lg" -> "px-5 py-2.5 text-base"
      _    -> "px-4 py-2 text-sm"
    end
    "#{base} #{size_pad}"
  end

  defp active_tab_class("underline"), do: "border-avn-purple text-avn-purple"
  defp active_tab_class("pills"),     do: "bg-avn-card text-avn-foreground shadow-avn-sm"
  defp active_tab_class("boxed"),     do: "bg-avn-card text-avn-foreground"

  defp inactive_tab_class("underline"), do: "border-transparent text-avn-muted-foreground hover:text-avn-foreground hover:border-avn-border"
  defp inactive_tab_class("pills"),     do: "text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted-hover"
  defp inactive_tab_class("boxed"),     do: "text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted-hover"

  defp badge_class("underline", true),  do: "ml-1 px-1.5 py-0.5 text-xs rounded-full bg-avn-purple text-white"
  defp badge_class("underline", false), do: "ml-1 px-1.5 py-0.5 text-xs rounded-full bg-avn-muted text-avn-muted-foreground"
  defp badge_class(_, true),   do: "ml-1 px-1.5 py-0.5 text-xs rounded-full bg-avn-purple/20 text-avn-purple"
  defp badge_class(_, false),  do: "ml-1 px-1.5 py-0.5 text-xs rounded-full bg-avn-muted text-avn-muted-foreground"
end
