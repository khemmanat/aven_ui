defmodule AvenUI.Components.Card do
  @moduledoc """
  Card container with composable header, body, and footer slots.

  ## Examples

      <%# Simple card with all slots %>
      <.card>
        <:header>
          <.card_title>Server #3</.card_title>
          <.card_description>Last ping 2s ago</.card_description>
        </:header>
        <:body>
          <p>CPU: 14%</p>
        </:body>
        <:footer>
          <.button size="sm">Restart</.button>
        </:footer>
      </.card>

      <%# Flat variant (no shadow, minimal border) %>
      <.card variant="flat" class="p-6">
        Content here
      </.card>

      <%# With hover effect for clickable cards %>
      <.card variant="interactive" phx-click="select" phx-value-id={@item.id}>
        Clickable card
      </.card>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :variant, :string, default: "default", values: ~w(default flat interactive)
  attr :padding, :string, default: "md",       values: ~w(none sm md lg)
  attr :class,   :string, default: nil
  attr :rest,    :global,  include: ~w(phx-click phx-target id)
  slot :header
  slot :body
  slot :footer
  slot :inner_block

  @variant_classes %{
    "default"     => "bg-avn-card border border-avn-border rounded-avn-lg",
    "flat"        => "bg-avn-muted border border-avn-border rounded-avn-lg",
    "interactive" => "bg-avn-card border border-avn-border rounded-avn-lg cursor-pointer hover:border-avn-purple/40 hover:shadow-sm transition-all duration-150"
  }

  def card(assigns) do
    ~H"""
    <div
      class={classes([variant_class(@variant), @class])}
      {@rest}
    >
      <%= if @header != [] do %>
        <div class="px-5 py-4 border-b border-avn-border">
          <%= render_slot(@header) %>
        </div>
      <% end %>

      <%= if @body != [] do %>
        <div class={["px-5 py-4", body_padding(@padding)]}>
          <%= render_slot(@body) %>
        </div>
      <% end %>

      <%# Fallback: inner_block without named slots %>
      <%= if @inner_block != [] and @body == [] do %>
        <div class={card_padding(@padding)}>
          <%= render_slot(@inner_block) %>
        </div>
      <% end %>

      <%= if @footer != [] do %>
        <div class="px-5 py-3 border-t border-avn-border bg-avn-muted/50 rounded-b-avn-lg">
          <%= render_slot(@footer) %>
        </div>
      <% end %>
    </div>
    """
  end

  @doc "Card title — rendered inside `:header` slot."
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def card_title(assigns) do
    ~H"""
    <h3 class={classes(["text-base font-medium text-avn-foreground leading-tight", @class])}>
      <%= render_slot(@inner_block) %>
    </h3>
    """
  end

  @doc "Card description — muted subtitle inside `:header` slot."
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def card_description(assigns) do
    ~H"""
    <p class={classes(["text-sm text-avn-muted-foreground mt-0.5", @class])}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp variant_class(v), do: Map.get(@variant_classes, v, @variant_classes["default"])

  defp card_padding("none"), do: ""
  defp card_padding("sm"),   do: "p-3"
  defp card_padding("md"),   do: "p-5"
  defp card_padding("lg"),   do: "p-7"
  defp card_padding(_),      do: "p-5"

  defp body_padding("none"), do: "!p-0"
  defp body_padding(_),      do: ""
end
