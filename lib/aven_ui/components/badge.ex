defmodule AvenUI.Components.Badge do
  @moduledoc """
  Badge component for status indicators, labels, and counts.

  ## Variants

  - `default`   — neutral gray
  - `primary`   — purple brand
  - `success`   — green
  - `warning`   — amber
  - `danger`    — red
  - `info`      — blue
  - `outline`   — transparent with border

  ## Examples

      <.badge>Default</.badge>

      <.badge variant="success">
        <.badge_dot /> Online
      </.badge>

      <.badge variant="danger" size="lg">Expired</.badge>

      <%# Count badge %>
      <.badge variant="primary">42</.badge>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @base_classes """
  inline-flex items-center gap-1.5 whitespace-nowrap
  rounded-full border px-2.5 font-medium
  transition-colors
  """

  @variant_classes %{
    "default" => "bg-avn-muted text-avn-foreground border-avn-border",
    "primary" => "bg-violet-100 text-violet-800 border-violet-200 dark:bg-violet-900/30 dark:text-violet-300 dark:border-violet-700",
    "success" => "bg-green-50  text-green-700  border-green-200  dark:bg-green-900/30 dark:text-green-400  dark:border-green-700",
    "warning" => "bg-amber-50  text-amber-700  border-amber-200  dark:bg-amber-900/30 dark:text-amber-400  dark:border-amber-700",
    "danger"  => "bg-red-50    text-red-700    border-red-200    dark:bg-red-900/30   dark:text-red-400    dark:border-red-700",
    "info"    => "bg-blue-50   text-blue-700   border-blue-200   dark:bg-blue-900/30  dark:text-blue-400   dark:border-blue-700",
    "outline" => "bg-transparent text-avn-foreground border-avn-border"
  }

  @size_classes %{
    "sm" => "py-0 text-xs",
    "md" => "py-0.5 text-xs",
    "lg" => "py-1 text-sm"
  }

  attr :variant, :string, default: "default", values: ~w(default primary success warning danger info outline)
  attr :size,    :string, default: "md",       values: ~w(sm md lg)
  attr :class,   :string, default: nil
  attr :rest,    :global
  slot :inner_block, required: true

  def badge(assigns) do
    ~H"""
    <span
      class={classes([
        String.trim(@base_classes),
        variant_class(@variant),
        size_class(@size),
        @class
      ])}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  @doc "Dot indicator inside a badge — inherits color via `currentColor`."
  attr :class, :string, default: nil

  def badge_dot(assigns) do
    ~H"""
    <span class={classes(["h-1.5 w-1.5 rounded-full bg-current shrink-0", @class])} aria-hidden="true" />
    """
  end

  defp variant_class(v), do: Map.get(@variant_classes, v, @variant_classes["default"])
  defp size_class(s),    do: Map.get(@size_classes, s, @size_classes["md"])
end
