defmodule AvenUI.Components.Breadcrumb do
  @moduledoc """
  Breadcrumb navigation component for showing page hierarchy.

  ## Features

  - Semantic navigation structure
  - Responsive design
  - Customizable separators
  - Home link support
  - Collapsed mobile view

  ## Examples

      <%!-- Basic breadcrumb --%>
      <.breadcrumb>
        <:item href="/dashboard">Dashboard</:item>
        <:item href="/projects">Projects</:item>
        <:item active>Project Details</:item>
      </.breadcrumb>

      <%!-- With custom separator --%>
      <.breadcrumb separator="→">
        <:item href="/">Home</:item>
        <:item href="/products">Products</:item>
        <:item active>Product Details</:item>
      </.breadcrumb>

      <%!-- Icon breadcrumb --%>
      <.breadcrumb>
        <:item href="/"><.icon name="home" /></:item>
        <:item href="/settings">Settings</:item>
        <:item active>Profile</:item>
      </.breadcrumb>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :separator, :string, default: "/", doc: "Separator between items"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :item, required: true do
    attr :href, :string
    attr :active, :boolean
    attr :icon, :boolean
  end

  def breadcrumb(assigns) do
    ~H"""
    <nav
      class={classes(["flex items-center gap-2 text-sm", @class])}
      aria-label="Breadcrumb"
      {@rest}
    >
      <ol class="flex items-center gap-2">
        <%= for {item, index} <- Enum.with_index(@item) do %>
          <li class="flex items-center gap-2">
            <%= if item[:active] do %>
              <span
                class="font-medium text-avn-foreground"
                aria-current="page"
              >
                <%= render_slot(item) %>
              </span>
            <% else %>
              <a
                href={item[:href]}
                class="text-avn-muted-foreground hover:text-avn-foreground transition-colors"
              >
                <%= render_slot(item) %>
              </a>
            <% end %>

            <%= if index < length(@item) - 1 do %>
              <span class="text-avn-muted-foreground" aria-hidden="true">
                <%= @separator %>
              </span>
            <% end %>
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end

  @doc """
  Breadcrumb item with icon support.
  """
  attr :href, :string
  attr :active, :boolean, default: false
  attr :icon, :string, default: nil
  slot :inner_block

  def breadcrumb_item(assigns) do
    ~H"""
    <%= if @active do %>
      <span class="font-medium text-avn-foreground" aria-current="page">
        <%= if @icon do %>
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d={@icon} />
          </svg>
        <% end %>
        <%= render_slot(@inner_block) %>
      </span>
    <% else %>
      <a
        href={@href}
        class="text-avn-muted-foreground hover:text-avn-foreground transition-colors flex items-center gap-1"
      >
        <%= if @icon do %>
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d={@icon} />
          </svg>
        <% end %>
        <%= render_slot(@inner_block) %>
      </a>
    <% end %>
    """
  end
end