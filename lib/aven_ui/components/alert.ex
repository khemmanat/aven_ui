defmodule AvenUI.Components.Alert do
  @moduledoc """
  Alert/notification banners for inline feedback messages.

  Supports an optional title, description slot, dismissible behavior
  via LiveView events, and an icon slot for custom icons.

  ## Examples

      <.alert variant="success" title="Deployment complete">
        Version 2.4.1 is now live across 3 nodes.
      </.alert>

      <.alert variant="warning" title="High memory usage" dismissible phx-click="dismiss_alert">
        Node #3 is at 87% — consider restarting.
      </.alert>

      <.alert variant="danger">
        <:icon><.icon name="hero-exclamation-circle" /></:icon>
        <:title>Database error</:title>
        Cannot connect to Postgres on port 5432.
      </.alert>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @base_classes "relative flex gap-3 rounded-elx border p-4 text-sm"

  @variant_classes %{
    "info"    => "bg-blue-50  border-blue-200  text-blue-800  [&_.alert-icon]:text-blue-500  dark:bg-blue-950/40  dark:border-blue-800  dark:text-blue-300",
    "success" => "bg-green-50 border-green-200 text-green-800 [&_.alert-icon]:text-green-500 dark:bg-green-950/40 dark:border-green-800 dark:text-green-300",
    "warning" => "bg-amber-50 border-amber-200 text-amber-800 [&_.alert-icon]:text-amber-500 dark:bg-amber-950/40 dark:border-amber-800 dark:text-amber-300",
    "danger"  => "bg-red-50   border-red-200   text-red-800   [&_.alert-icon]:text-red-500   dark:bg-red-950/40   dark:border-red-800   dark:text-red-300"
  }

  @default_icons %{
    "info"    => "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
    "success" => "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z",
    "warning" => "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z",
    "danger"  => "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
  }

  attr :variant,     :string,  default: "info", values: ~w(info success warning danger)
  attr :title,       :string,  default: nil
  attr :dismissible, :boolean, default: false
  attr :class,       :string,  default: nil
  attr :rest,        :global,  include: ~w(phx-click phx-target)
  slot :icon
  slot :title, doc: "Optional named slot for the title (alternative to `title` attr)"
  slot :inner_block

  def alert(assigns) do
    ~H"""
    <div
      role="alert"
      class={classes([String.trim(@base_classes), variant_class(@variant), @class])}
    >
      <%# Icon: prefer slot, fall back to default SVG %>
      <div class="alert-icon mt-0.5 shrink-0">
        <%= if @icon != [] do %>
          <%= render_slot(@icon) %>
        <% else %>
          <svg class="h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
               stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d={default_icon(@variant)} />
          </svg>
        <% end %>
      </div>

      <div class="flex-1 min-w-0">
        <%# Title: prefer named slot, then attr %>
        <%= if @title != [] do %>
          <p class="font-medium leading-snug mb-0.5"><%= render_slot(@title) %></p>
        <% else %>
          <%= if @title do %>
            <p class="font-medium leading-snug mb-0.5"><%= @title %></p>
          <% end %>
        <% end %>

        <%= if @inner_block != [] do %>
          <p class="opacity-90 leading-relaxed"><%= render_slot(@inner_block) %></p>
        <% end %>
      </div>

      <%= if @dismissible do %>
        <button
          type="button"
          class="shrink-0 ml-auto -mt-0.5 -mr-1 rounded p-1 opacity-60 hover:opacity-100 transition-opacity"
          aria-label="Dismiss"
          {@rest}
        >
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      <% end %>
    </div>
    """
  end

  defp variant_class(v), do: Map.get(@variant_classes, v, @variant_classes["info"])
  defp default_icon(v),  do: Map.get(@default_icons, v, @default_icons["info"])
end
