defmodule AvenUI.Components.Accordion do
  @moduledoc """
  Accordion / disclosure component using pure Phoenix LiveView JS — no hooks needed.

  ## Examples

      <.accordion id="faq">
        <:item title="What is AvenUI?">
          A free component library for Phoenix LiveView.
        </:item>
        <:item title="Is it free?" open>
          Yes. MIT licensed. You own the code.
        </:item>
      </.accordion>

      <.accordion id="settings" variant="flush">
        <:item title="Privacy"><p>...</p></:item>
      </.accordion>
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import AvenUI.Helpers

  attr :id,      :string, required: true
  attr :variant, :string, default: "bordered", values: ~w(bordered flush)
  attr :class,   :string, default: nil

  slot :item, required: true do
    attr :title, :string, required: true
    attr :open,  :boolean
  end

  def accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={classes([
        if(@variant == "bordered", do: "rounded-avn-lg border border-avn-border divide-y divide-avn-border overflow-hidden"),
        if(@variant == "flush",    do: "divide-y divide-avn-border"),
        @class
      ])}
    >
      <%= for {item, idx} <- Enum.with_index(@item) do %>
        <% item_id = "#{@id}-item-#{idx}" %>
        <div id={item_id}>
          <button
            type="button"
            aria-expanded={to_string(item[:open] || false)}
            aria-controls={"#{item_id}-panel"}
            phx-click={toggle_item(item_id)}
            class={classes([
              "flex w-full items-center justify-between gap-4 text-left",
              "text-sm font-medium text-avn-foreground",
              "hover:bg-avn-muted transition-colors duration-100",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple focus-visible:ring-inset",
              if(@variant == "bordered", do: "px-5 py-4", else: "py-4")
            ])}
          >
            <span><%= item.title %></span>
            <svg
              class="h-4 w-4 shrink-0 text-avn-muted-foreground transition-transform duration-200 [[aria-expanded=true]_&]:rotate-180"
              viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
              aria-hidden="true"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
            </svg>
          </button>

          <div
            id={"#{item_id}-panel"}
            role="region"
            hidden={!(item[:open] || false)}
            class={classes([
              "text-sm text-avn-muted-foreground leading-relaxed",
              if(@variant == "bordered", do: "px-5 pb-4", else: "pb-4")
            ])}
          >
            <%= render_slot(item) %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp toggle_item(item_id) do
    %JS{}
    |> JS.toggle(to: "##{item_id}-panel")
    |> JS.toggle_attribute({"aria-expanded", "true", "false"}, to: "##{item_id} button")
  end
end
