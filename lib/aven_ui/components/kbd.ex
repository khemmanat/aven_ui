defmodule AvenUI.Components.Kbd do
  @moduledoc """
  Keyboard shortcut display.

  ## Examples

      <.kbd>⌘</.kbd><.kbd>K</.kbd>
      <.kbd>Ctrl + S</.kbd>
      <.kbd>Escape</.kbd>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def kbd(assigns) do
    ~H"""
    <kbd class={classes([
      "inline-flex items-center justify-center px-1.5 py-0.5 min-w-[1.5rem]",
      "text-xs font-mono font-medium text-avn-muted-foreground",
      "bg-avn-muted border border-avn-border border-b-2",
      "rounded shadow-avn-sm select-none",
      @class
    ])}>
      <%= render_slot(@inner_block) %>
    </kbd>
    """
  end
end
