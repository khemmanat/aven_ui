defmodule AvenUI.Components.EmptyState do
  @moduledoc """
  Empty state with icon, title, description, and optional action slot.

  ## Examples

      <.empty_state
        title="No deployments yet"
        description="Push a commit to trigger your first deploy."
      >
        <.button variant="secondary" size="sm">Read the docs</.button>
      </.empty_state>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :title,       :string, required: true
  attr :description, :string, default: nil
  attr :icon_path,   :string, default: nil, doc: "Custom SVG path d= attribute"
  attr :class,       :string, default: nil
  slot :inner_block

  @doc """
  Renders an empty state with icon, title, description, and optional action.
  """
  def empty_state(assigns) do
    ~H"""
    <div class={classes(["flex flex-col items-center justify-center gap-4 py-16 px-4 text-center", @class])}>
      <div class="flex h-14 w-14 items-center justify-center rounded-full bg-avn-muted border border-avn-border">
        <svg class="h-7 w-7 text-avn-muted-foreground" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d={@icon_path || "M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"} />
        </svg>
      </div>

      <div>
        <p class="text-base font-medium text-avn-foreground"><%= @title %></p>
        <p :if={@description} class="mt-1 text-sm text-avn-muted-foreground max-w-sm">
          <%= @description %>
        </p>
      </div>

      <div :if={@inner_block != []} class="mt-2">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
