defmodule AvenUI.Components.Skeleton do
  @moduledoc """
  Skeleton loader placeholder — shimmer animation for async content.

  ## Examples

      <.skeleton class="h-4 w-48" />
      <.skeleton class="h-10 w-10 rounded-full" />

      <%# Inside a card %>
      <div class="flex gap-3 items-start">
        <.skeleton class="h-10 w-10 rounded-full shrink-0" />
        <div class="flex-1 space-y-2 pt-1">
          <.skeleton class="h-3 w-3/5" />
          <.skeleton class="h-3 w-full" />
          <.skeleton class="h-3 w-4/5" />
        </div>
      </div>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :class, :string, default: nil

  @doc """
  Renders a skeleton loader placeholder with shimmer animation.
  """
  def skeleton(assigns) do
    ~H"""
    <div
      class={classes(["animate-pulse rounded bg-avn-muted", @class])}
      aria-hidden="true"
    />
    """
  end
end
