defmodule AvenUI.Components.Spinner do
  @moduledoc """
  Animated loading spinner — 5 sizes, inherits color via currentColor.

  ## Examples

      <.spinner />
      <.spinner size="lg" class="text-avn-purple" />
      <.spinner size="sm" />
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :size,  :string, default: "md", values: ~w(xs sm md lg xl)
  attr :class, :string, default: nil

  @doc """
  Renders an animated loading spinner.
  """
  def spinner(assigns) do
    ~H"""
    <svg
      class={classes(["animate-spin", size_class(@size), @class])}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      aria-label="Loading"
      role="status"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
    </svg>
    """
  end

  defp size_class("xs"), do: "h-3 w-3"
  defp size_class("sm"), do: "h-4 w-4"
  defp size_class("md"), do: "h-5 w-5"
  defp size_class("lg"), do: "h-7 w-7"
  defp size_class("xl"), do: "h-10 w-10"
  defp size_class(_),    do: "h-5 w-5"
end
