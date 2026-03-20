defmodule AvenUI.Components.Progress do
  @moduledoc """
  Progress bar component with label, value display, colors, and sizes.

  ## Examples

      <.progress value={72} />
      <.progress value={45} label="Uploading" show_value color="blue" />
      <.progress value={100} color="green" label="Complete" show_value size="lg" />
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @color_classes %{
    "purple" => "bg-avn-purple",
    "blue"   => "bg-blue-500",
    "green"  => "bg-green-500",
    "amber"  => "bg-amber-500",
    "red"    => "bg-red-500"
  }

  @size_classes %{
    "xs" => "h-1",
    "sm" => "h-1.5",
    "md" => "h-2",
    "lg" => "h-3",
    "xl" => "h-4"
  }

  attr :value,      :integer, required: true, doc: "0 to 100"
  attr :label,      :string,  default: nil
  attr :show_value, :boolean, default: false
  attr :color,      :string,  default: "purple", values: ~w(purple blue green amber red)
  attr :size,       :string,  default: "md",     values: ~w(xs sm md lg xl)
  attr :animated,   :boolean, default: true
  attr :class,      :string,  default: nil

  @doc """
  Renders a progress bar with optional label and value display.
  """
  def progress(assigns) do
    ~H"""
    <div class={classes(["w-full", @class])}>
      <%= if @label || @show_value do %>
        <div class="flex justify-between items-center mb-1.5">
          <span :if={@label} class="text-sm text-avn-muted-foreground"><%= @label %></span>
          <span :if={@show_value} class="text-sm font-medium text-avn-foreground"><%= @value %>%</span>
        </div>
      <% end %>

      <div
        class={classes(["w-full rounded-full bg-avn-muted overflow-hidden", size_class(@size)])}
        role="progressbar"
        aria-valuenow={@value}
        aria-valuemin="0"
        aria-valuemax="100"
      >
        <div
          class={classes([
            "h-full rounded-full",
            color_class(@color),
            if(@animated, do: "transition-[width] duration-500 ease-out")
          ])}
          style={"width: #{min(@value, 100)}%"}
        />
      </div>
    </div>
    """
  end

  defp color_class(c), do: Map.get(@color_classes, c, @color_classes["purple"])
  defp size_class(s),  do: Map.get(@size_classes, s, @size_classes["md"])
end
