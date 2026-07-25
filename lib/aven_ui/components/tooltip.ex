defmodule AvenUI.Components.Tooltip do
  @moduledoc """
  Tooltip component for contextual help and information.

  ## Features

  - Position-aware (top, bottom, left, right)
  - Keyboard accessible
  - Delay customization
  - Arrow indicator
  - Responsive positioning

  ## Examples

      <%!-- Basic tooltip --%>
      <.tooltip content="Save your changes">
        <.button>Save</.button>
      </.tooltip>

      <%!-- Positioned tooltip --%>
      <.tooltip content="Delete item" position="bottom">
        <.button variant="danger">Delete</.button>
      </.tooltip>

      <%!-- With delay --%>
      <.tooltip content="Loading..." delay={1000}>
        <.button>Load</.button>
      </.tooltip>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @positions ~w(top bottom left right)

  attr :id, :string, required: true
  attr :content, :string, required: true, doc: "Tooltip content text"
  attr :position, :string, default: "top", values: @positions
  attr :delay, :integer, default: 300, doc: "Show delay in milliseconds"
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def tooltip(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Tooltip"
      data-position={@position}
      data-delay={@delay}
      data-disabled={@disabled}
      class={classes(["relative inline-block", @class])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>

      <div
        data-avn-tooltip
        role="tooltip"
        class={classes([
          "absolute z-[var(--avn-z-tooltip)] px-2.5 py-1.5 text-xs font-medium",
          "bg-avn-foreground text-avn-background rounded-avn shadow-avn-md",
          "opacity-0 pointer-events-none transition-opacity duration-200",
          "whitespace-nowrap max-w-xs",
          position_class(@position),
          if(@disabled, do: "hidden", else: "")
        ])}
      >
        <%= @content %>

        <%!-- Arrow indicator --%>
        <div class={classes([
          "absolute w-2 h-2 bg-avn-foreground transform rotate-45",
          arrow_position_class(@position)
        ])} />
      </div>
    </div>
    """
  end

  defp position_class("top"), do: "bottom-full left-1/2 -translate-x-1/2 mb-2"
  defp position_class("bottom"), do: "top-full left-1/2 -translate-x-1/2 mt-2"
  defp position_class("left"), do: "right-full top-1/2 -translate-y-1/2 mr-2"
  defp position_class("right"), do: "left-full top-1/2 -translate-y-1/2 ml-2"

  defp arrow_position_class("top"), do: "-bottom-1 left-1/2 -translate-x-1/2"
  defp arrow_position_class("bottom"), do: "-top-1 left-1/2 -translate-x-1/2"
  defp arrow_position_class("left"), do: "-right-1 top-1/2 -translate-y-1/2"
  defp arrow_position_class("right"), do: "-left-1 top-1/2 -translate-y-1/2"
end