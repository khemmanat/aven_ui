defmodule AvenUI.Components.Dropdown do
  @moduledoc """
  Dropdown menu component using Phoenix LiveView's built-in `JS` commands.

  Zero external JS dependency — uses `Phoenix.LiveView.JS` for show/hide,
  with the `Dropdown` hook handling keyboard navigation and outside-click.

  ## Examples

      <%# Basic action menu %>
      <.dropdown id="actions-menu">
        <:trigger>
          <.button variant="secondary" size="sm">
            Options
            <.dropdown_chevron />
          </.button>
        </:trigger>

        <.dropdown_item phx-click="edit">Edit</.dropdown_item>
        <.dropdown_item phx-click="duplicate">Duplicate</.dropdown_item>
        <.dropdown_separator />
        <.dropdown_item variant="danger" phx-click="delete">Delete</.dropdown_item>
      </.dropdown>

      <%# With icons and labels %>
      <.dropdown id="user-menu" align="right">
        <:trigger>
          <.avatar initials="KN" size="sm" class="cursor-pointer" />
        </:trigger>

        <.dropdown_label>Khemmanat N.</.dropdown_label>
        <.dropdown_separator />
        <.dropdown_item>
          <:icon>
            <svg class="h-4 w-4" .../>
          </:icon>
          Profile settings
        </.dropdown_item>
        <.dropdown_item phx-click="logout">Sign out</.dropdown_item>
      </.dropdown>

      <%# Grouped with labels %>
      <.dropdown id="view-menu">
        <:trigger><.button variant="ghost" size="sm">View</.button></:trigger>

        <.dropdown_label>Layout</.dropdown_label>
        <.dropdown_item><.dropdown_check checked={@view == "list"} /> List</.dropdown_item>
        <.dropdown_item><.dropdown_check checked={@view == "grid"} /> Grid</.dropdown_item>
        <.dropdown_separator />
        <.dropdown_label>Sort</.dropdown_label>
        <.dropdown_item phx-click="sort" phx-value-by="name">Name</.dropdown_item>
        <.dropdown_item phx-click="sort" phx-value-by="date">Date</.dropdown_item>
      </.dropdown>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :id,    :string,  required: true
  attr :align, :string,  default: "left", values: ~w(left right)
  attr :class, :string,  default: nil
  slot :trigger, required: true
  slot :inner_block, required: true

  @doc """
  Renders a dropdown menu with trigger and menu items.
  """
  def dropdown(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Dropdown"
      class={classes(["relative inline-block", @class])}
    >
      <%# Trigger wrapper — hook binds click/keydown here %>
      <div data-avn-dropdown-trigger aria-haspopup="true" aria-expanded="false" aria-controls={"#{@id}-menu"}>
        <%= render_slot(@trigger) %>
      </div>

      <%# Menu panel %>
      <div
        id={"#{@id}-menu"}
        data-avn-dropdown-menu
        hidden
        role="menu"
        aria-labelledby={@id}
        class={classes([
          "absolute z-[var(--avn-z-dropdown)] mt-1.5 min-w-[180px]",
          "rounded-avn-lg border border-avn-border bg-avn-card",
          "shadow-avn-md py-1",
          "animate-fade-in",
          if(@align == "right", do: "right-0", else: "left-0")
        ])}
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc "Individual dropdown menu item."
  attr :variant, :string, default: "default", values: ~w(default danger)
  attr :disabled, :boolean, default: false
  attr :class,   :string,  default: nil
  attr :rest,    :global,  include: ~w(phx-click phx-value phx-target href)
  slot :icon
  slot :inner_block, required: true

  def dropdown_item(assigns) do
    ~H"""
    <button
      type="button"
      role="menuitem"
      disabled={@disabled}
      data-avn-dropdown-item
      class={classes([
        "w-full flex items-center gap-2 px-3 py-2 text-sm text-left",
        "transition-colors duration-100",
        "focus:outline-none focus-visible:bg-avn-muted",
        "disabled:pointer-events-none disabled:opacity-50",
        if(@variant == "danger",
          do: "text-red-600 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-950/40",
          else: "text-avn-foreground hover:bg-avn-muted"
        ),
        @class
      ])}
      {@rest}
    >
      <%= if @icon != [] do %>
        <span class="shrink-0 text-avn-muted-foreground [&>svg]:h-4 [&>svg]:w-4">
          <%= render_slot(@icon) %>
        </span>
      <% end %>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc "Visual separator line between groups."
  attr :class, :string, default: nil

  def dropdown_separator(assigns) do
    ~H"""
    <div class={classes(["my-1 h-px bg-avn-border mx-1", @class])} role="separator" />
    """
  end

  @doc "Section label / group header inside a dropdown."
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dropdown_label(assigns) do
    ~H"""
    <p class={classes(["px-3 py-1.5 text-xs font-medium text-avn-muted-foreground uppercase tracking-wide", @class])}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc "Checkmark indicator for toggleable menu items."
  attr :checked, :boolean, default: false

  def dropdown_check(assigns) do
    ~H"""
    <span class="inline-flex h-4 w-4 items-center justify-center shrink-0">
      <%= if @checked do %>
        <svg class="h-3.5 w-3.5 text-avn-purple" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/>
        </svg>
      <% end %>
    </span>
    """
  end

  @doc "Chevron icon for trigger buttons — auto-rotates when open."
  attr :class, :string, default: nil

  def dropdown_chevron(assigns) do
    ~H"""
    <svg
      class={classes(["h-4 w-4 shrink-0 transition-transform duration-150 [[aria-expanded=true]_&]:rotate-180", @class])}
      viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
      aria-hidden="true"
    >
      <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
    </svg>
    """
  end
end
