defmodule AvenUI.Components.Separator do
  @moduledoc """
  Horizontal or vertical separator line with optional label.

  ## Examples

      <.separator />
      <.separator label="or continue with" />
      <.separator orientation="vertical" class="h-6" />
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :label,       :string, default: nil
  attr :class,       :string, default: nil

  @doc """
  Renders a horizontal or vertical separator with optional label.
  """
  def separator(assigns) do
    ~H"""
    <%= if @label do %>
      <div class={classes(["flex items-center gap-3 text-xs text-avn-muted-foreground", @class])}>
        <div class="flex-1 h-px bg-avn-border" />
        <span><%= @label %></span>
        <div class="flex-1 h-px bg-avn-border" />
      </div>
    <% else %>
      <div
        role="separator"
        aria-orientation={@orientation}
        class={classes([
          "bg-avn-border shrink-0",
          if(@orientation == "vertical", do: "w-px h-full", else: "h-px w-full"),
          @class
        ])}
      />
    <% end %>
    """
  end
end
