defmodule AvenUI.Components.Avatar do
  @moduledoc """
  Avatar component — initials or image, with size, color, and stack variants.

  ## Examples

      <.avatar initials="KN" />
      <.avatar initials="KN" size="lg" color="green" />
      <.avatar src="https://..." alt="Khemmanat" />

      <%# Stacked group %>
      <.avatar_group>
        <.avatar initials="KN" />
        <.avatar initials="AB" color="amber" />
        <.avatar initials="+3" color="gray" />
      </.avatar_group>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @size_classes %{
    "xs" => "h-6 w-6 text-xs",
    "sm" => "h-8 w-8 text-xs",
    "md" => "h-9 w-9 text-sm",
    "lg" => "h-11 w-11 text-base",
    "xl" => "h-14 w-14 text-lg"
  }

  @color_classes %{
    "purple" => "bg-violet-100 text-violet-800 border-violet-200 dark:bg-violet-900/30 dark:text-violet-300",
    "blue"   => "bg-blue-100   text-blue-800   border-blue-200   dark:bg-blue-900/30   dark:text-blue-300",
    "green"  => "bg-green-100  text-green-800  border-green-200  dark:bg-green-900/30  dark:text-green-300",
    "amber"  => "bg-amber-100  text-amber-800  border-amber-200  dark:bg-amber-900/30  dark:text-amber-300",
    "red"    => "bg-red-100    text-red-800    border-red-200    dark:bg-red-900/30    dark:text-red-300",
    "gray"   => "bg-avn-muted  text-avn-muted-foreground border-avn-border"
  }

  attr :initials, :string,  default: nil
  attr :src,      :string,  default: nil
  attr :alt,      :string,  default: ""
  attr :size,     :string,  default: "md", values: ~w(xs sm md lg xl)
  attr :color,    :string,  default: "purple", values: ~w(purple blue green amber red gray)
  attr :class,    :string,  default: nil

  def avatar(assigns) do
    ~H"""
    <div class={classes([
      "inline-flex items-center justify-center shrink-0",
      "rounded-full border font-medium overflow-hidden",
      size_class(@size),
      if(@src, do: "border-avn-border", else: color_class(@color)),
      @class
    ])}>
      <%= if @src do %>
        <img src={@src} alt={@alt} class="h-full w-full object-cover" />
      <% else %>
        <span><%= @initials %></span>
      <% end %>
    </div>
    """
  end

  @doc "Stack multiple avatars with overlap."
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def avatar_group(assigns) do
    ~H"""
    <div class={classes(["flex items-center [&>*:not(:first-child)]:-ml-2", @class])}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  defp size_class(s),  do: Map.get(@size_classes, s, @size_classes["md"])
  defp color_class(c), do: Map.get(@color_classes, c, @color_classes["purple"])
end
