defmodule AvenUI.Components.Sidebar do
  @moduledoc """
  Responsive sidebar navigation component for admin dashboards and applications.

  ## Features

  - Collapsible navigation
  - Mobile responsive with overlay
  - Multiple layout modes
  - Active state tracking
  - Nested navigation support
  - Badge/indicator support

  ## Examples

      <%!-- Basic sidebar --%>
      <.sidebar>
        <:header>
          <.sidebar_logo>MyApp</.sidebar_logo>
        </:header>

        <:nav>
          <.sidebar_item href="/dashboard" active={@current_path == "/dashboard"}>
            Dashboard
          </.sidebar_item>
          <.sidebar_item href="/users">
            Users
          </.sidebar_item>
        </:nav>

        <:footer>
          <.sidebar_user user={@current_user} />
        </:footer>
      </.sidebar>

      <%!-- Collapsible sidebar --%>
      <.sidebar collapsible collapsed={@collapsed}>
        <:nav>
          <.sidebar_item href="/settings">Settings</.sidebar_item>
        </:nav>
      </.sidebar>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :id, :string, required: true
  attr :collapsible, :boolean, default: false
  attr :collapsed, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :header, doc: "Logo and branding section"
  slot :nav, required: true, doc: "Navigation items"
  slot :footer, doc: "User info and additional actions"

  def sidebar(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Sidebar"
      data-collapsible={@collapsible}
      data-collapsed={@collapsed}
      class={classes([
        "fixed inset-y-0 left-0 z-40 flex",
        "transition-transform duration-300 ease-in-out",
        if(@collapsed, do: "-translate-x-full", else: "translate-x-0"),
        @class
      ])}
      {@rest}
    >
      <%!-- Backdrop for mobile --%>
      <div
        data-avn-sidebar-backdrop
        class="fixed inset-0 bg-black/50 z-[-1] hidden lg:hidden"
        phx-click="close_sidebar"
      />

      <%!-- Sidebar content --%>
      <div class={classes([
        "flex flex-col w-64 h-full bg-avn-card border-r border-avn-border",
        "transition-all duration-300",
        if(@collapsed && @collapsible, do: "w-20", else: "w-64")
      ])}>
        <%!-- Header --%>
        <%= if @header != [] do %>
          <div class="flex items-center justify-between h-16 px-4 border-b border-avn-border shrink-0">
            <%= render_slot(@header) %>
            <%= if @collapsible do %>
              <button
                phx-click="toggle_sidebar"
                class="p-1.5 rounded-avn hover:bg-avn-muted text-avn-muted-foreground hover:text-avn-foreground transition-colors"
                aria-label="Toggle sidebar"
              >
                <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M11 19l-7-7 7-7M18 19l-7-7 7-7"/>
                </svg>
              </button>
            <% end %>
          </div>
        <% end %>

        <%!-- Navigation --%>
        <nav class="flex-1 overflow-y-auto py-4 px-3 space-y-1">
          <%= render_slot(@nav) %>
        </nav>

        <%!-- Footer --%>
        <%= if @footer != [] do %>
          <div class="border-t border-avn-border p-4 shrink-0">
            <%= render_slot(@footer) %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Sidebar logo/title component.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def sidebar_logo(assigns) do
    ~H"""
    <div class={classes(["flex items-center gap-3 font-semibold text-avn-foreground", @class])}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Sidebar navigation item.
  """
  attr :href, :string, required: true
  attr :active, :boolean, default: false
  attr :icon, :string, default: nil
  attr :badge, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def sidebar_item(assigns) do
    ~H"""
    <a
      href={@href}
      class={classes([
        "flex items-center gap-3 px-3 py-2.5 rounded-avn text-sm font-medium",
        "transition-colors duration-150",
        "focus:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple",
        if(@active,
          do: "bg-avn-purple text-white",
          else: "text-avn-muted-foreground hover:bg-avn-muted hover:text-avn-foreground"
        ),
        if(@disabled, do: "opacity-50 cursor-not-allowed", else: ""),
        @class
      ])}
      {@rest}
    >
      <%= if @icon do %>
        <svg class="w-5 h-5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d={@icon} />
        </svg>
      <% end %>

      <span class="flex-1 truncate">
        <%= render_slot(@inner_block) %>
      </span>

      <%= if @badge do %>
        <span class="ml-auto bg-avn-purple text-white text-xs px-2 py-0.5 rounded-full">
          <%= @badge %>
        </span>
      <% end %>
    </a>
    """
  end

  @doc """
  Sidebar user section.
  """
  attr :user, :map, required: true
  attr :class, :string, default: nil

  def sidebar_user(assigns) do
    ~H"""
    <div class={classes(["flex items-center gap-3", @class])}>
      <div class="w-8 h-8 rounded-full bg-avn-purple flex items-center justify-center text-white text-sm font-medium">
        <%= String.slice(@user.name || "U", 0..1) %>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium text-avn-foreground truncate">
          <%= @user.name || "User" %>
        </p>
        <p class="text-xs text-avn-muted-foreground truncate">
          <%= @user.email || "user@example.com" %>
        </p>
      </div>
    </div>
    """
  end

  @doc """
  Sidebar section divider.
  """
  attr :label, :string, default: nil
  attr :class, :string, default: nil

  def sidebar_divider(assigns) do
    ~H"""
    <div class={classes(["mt-6 mb-2", @class])}>
      <%= if @label do %>
        <p class="px-3 text-xs font-semibold text-avn-muted-foreground uppercase tracking-wider">
          <%= @label %>
        </p>
      <% else %>
        <div class="border-t border-avn-border" />
      <% end %>
    </div>
    """
  end
end