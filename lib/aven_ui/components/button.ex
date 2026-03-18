defmodule AvenUI.Components.Button do
  @moduledoc """
  Button component with full variant, size, loading, and icon support.

  ## Variants

  - `primary`   — filled purple, main CTA
  - `secondary` — outlined, secondary actions
  - `ghost`     — no border, subtle actions
  - `danger`    — red tint, destructive actions
  - `outline`   — neutral outline
  - `link`      — looks like a hyperlink

  ## Sizes

  - `xs`, `sm`, `md` (default), `lg`, `xl`

  ## Examples

      <.button>Deploy</.button>

      <.button variant="secondary" size="sm">Cancel</.button>

      <.button variant="danger" phx-click="delete" phx-value-id={@item.id}>
        Delete project
      </.button>

      <.button loading={@saving}>
        <.button_icon><.spinner /></.button_icon>
        Saving…
      </.button>

      <.button variant="primary" size="lg" disabled>
        Locked
      </.button>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @base_classes """
  inline-flex items-center justify-center gap-2 whitespace-nowrap
  rounded-elx font-medium select-none border
  transition-all duration-150 ease-in-out
  focus-visible:outline-none focus-visible:ring-2
  focus-visible:ring-avn-purple focus-visible:ring-offset-2
  disabled:pointer-events-none disabled:opacity-50
  active:scale-[0.97]
  """

  @variant_classes %{
    "primary"   => "bg-avn-purple text-white border-avn-purple-dark hover:bg-avn-purple-dark",
    "secondary" => "bg-transparent text-avn-foreground border-avn-border hover:bg-avn-muted",
    "ghost"     => "bg-transparent text-avn-foreground border-transparent hover:bg-avn-muted",
    "danger"    => "bg-red-50 text-red-700 border-red-200 hover:bg-red-100 dark:bg-red-950 dark:text-red-400 dark:border-red-800",
    "outline"   => "bg-transparent text-avn-foreground border-avn-border hover:bg-avn-muted",
    "link"      => "bg-transparent text-avn-purple border-transparent underline-offset-4 hover:underline p-0 h-auto"
  }

  @size_classes %{
    "xs" => "h-7 px-2.5 text-xs rounded",
    "sm" => "h-8 px-3 text-sm",
    "md" => "h-9 px-4 text-sm",
    "lg" => "h-10 px-5 text-base",
    "xl" => "h-12 px-6 text-base"
  }

  attr :variant,  :string,  default: "primary",   values: ~w(primary secondary ghost danger outline link)
  attr :size,     :string,  default: "md",         values: ~w(xs sm md lg xl)
  attr :type,     :string,  default: "button",     values: ~w(button submit reset)
  attr :loading,  :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class,    :string,  default: nil
  attr :rest,     :global,  include: ~w(phx-click phx-submit phx-value phx-target form)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      disabled={@disabled || @loading}
      class={classes([
        String.trim(@base_classes),
        variant_class(@variant),
        size_class(@size),
        @class
      ])}
      {@rest}
    >
      <%= if @loading do %>
        <svg
          class="animate-spin h-4 w-4 shrink-0"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
        </svg>
      <% end %>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc "Icon wrapper inside a button — handles sizing consistently."
  slot :inner_block, required: true
  attr :class, :string, default: nil

  def button_icon(assigns) do
    ~H"""
    <span class={classes(["shrink-0 [&>svg]:h-4 [&>svg]:w-4", @class])}>
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  # Private helpers
  defp variant_class(v), do: Map.get(@variant_classes, v, @variant_classes["primary"])
  defp size_class(s),    do: Map.get(@size_classes, s, @size_classes["md"])
end
