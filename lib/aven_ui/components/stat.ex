defmodule AvenUI.Components.Stat do
  @moduledoc """
  Stat / metric card for dashboard KPIs.

  ## Examples

      <div class="grid grid-cols-3 gap-4">
        <.stat label="Deploys today" value="24"     change="+8"    trend="up" />
        <.stat label="Avg response"  value="142"    suffix="ms"    change="+12ms" trend="down" />
        <.stat label="Uptime (30d)"  value="99.97"  suffix="%"     />
      </div>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :label,   :string,  required: true
  attr :value,   :string,  required: true
  attr :change,  :string,  default: nil
  attr :trend,   :string,  default: nil, values: [nil, "up", "down", "neutral"]
  attr :prefix,  :string,  default: nil
  attr :suffix,  :string,  default: nil
  attr :loading, :boolean, default: false
  attr :class,   :string,  default: nil

  def stat(assigns) do
    ~H"""
    <div class={classes(["rounded-avn-lg bg-avn-muted border border-avn-border p-4", @class])}>
      <p class="text-xs font-medium text-avn-muted-foreground uppercase tracking-wide mb-2">
        <%= @label %>
      </p>

      <%= if @loading do %>
        <div class="space-y-2">
          <div class="animate-pulse h-7 w-24 rounded bg-avn-muted-hover" />
          <div class="animate-pulse h-3 w-16 rounded bg-avn-muted-hover" />
        </div>
      <% else %>
        <div class="flex items-baseline gap-1">
          <span :if={@prefix} class="text-sm text-avn-muted-foreground font-medium"><%= @prefix %></span>
          <span class="text-2xl font-medium text-avn-foreground tabular-nums"><%= @value %></span>
          <span :if={@suffix} class="text-sm text-avn-muted-foreground font-medium"><%= @suffix %></span>
        </div>

        <%= if @change do %>
          <div class={classes(["flex items-center gap-1 mt-1.5 text-xs font-medium", trend_class(@trend)])}>
            <svg :if={@trend == "up"} class="h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" d="M5 15l7-7 7 7"/>
            </svg>
            <svg :if={@trend == "down"} class="h-3 w-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
            </svg>
            <span><%= @change %></span>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp trend_class("up"),   do: "text-green-600 dark:text-green-400"
  defp trend_class("down"), do: "text-red-600 dark:text-red-400"
  defp trend_class(_),      do: "text-avn-muted-foreground"
end
