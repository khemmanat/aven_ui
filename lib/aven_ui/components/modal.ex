defmodule AvenUI.Components.Modal do
  @moduledoc """
  Modal / Dialog component for Phoenix LiveView.

  Uses a LiveView-native approach: visibility is controlled by a LiveView assign,
  the JS hook handles focus trapping, scroll locking, and Escape-to-close.

  ## Setup

  Requires the `Modal` JS hook from `AvenUIHooks` (already wired if you ran
  `mix aven_ui.add`).

  ## Examples

      <%# In your LiveView template %>
      <.button phx-click="open_modal">Open</.button>

      <.modal :if={@show_modal} id="confirm-modal" on_close="close_modal">
        <:title>Delete project?</:title>
        <:description>This action cannot be undone.</:description>

        <p>All data for <strong><%= @project.name %></strong> will be permanently deleted.</p>

        <:footer>
          <.button variant="ghost" phx-click="close_modal">Cancel</.button>
          <.button variant="danger" phx-click="delete_project" phx-value-id={@project.id}>
            Delete
          </.button>
        </:footer>
      </.modal>

  In your LiveView:

      def handle_event("open_modal",  _, socket), do: {:noreply, assign(socket, show_modal: true)}
      def handle_event("close_modal", _, socket), do: {:noreply, assign(socket, show_modal: false)}

  ## Sizes

  - `sm`  — 448px  (confirmations)
  - `md`  — 560px  (forms, default)
  - `lg`  — 720px  (complex content)
  - `xl`  — 960px  (full panels)
  - `full`— 100vw  (slideout style)
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import AvenUI.Helpers

  @size_classes %{
    "sm"   => "max-w-sm",
    "md"   => "max-w-lg",
    "lg"   => "max-w-2xl",
    "xl"   => "max-w-4xl",
    "full" => "max-w-full mx-4"
  }

  attr :id,       :string,  required: true
  attr :size,     :string,  default: "md", values: ~w(sm md lg xl full)
  attr :on_close, :string,  default: "close_modal", doc: "phx-click event name for close button"
  attr :class,    :string,  default: nil
  attr :rest,     :global

  slot :title,       doc: "Modal title shown in the header"
  slot :description, doc: "Subtitle/description below title"
  slot :inner_block, required: true, doc: "Modal body content"
  slot :footer,      doc: "Action buttons — rendered in the footer bar"

  def modal(assigns) do
    ~H"""
    <%# Backdrop + scroll lock via phx-mounted / JS hook %>
    <div
      id={@id}
      phx-hook="Modal"
      phx-remove={hide_modal(@id)}
      class="fixed inset-0 z-[var(--avn-z-modal)] flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby={"#{@id}-title"}
    >
      <%# Backdrop %>
      <div
        class="absolute inset-0 bg-black/50 backdrop-blur-[2px] animate-fade-in"
        phx-click={@on_close}
        aria-hidden="true"
      />

      <%# Panel %>
      <div class={classes([
        "relative z-10 w-full bg-avn-card border border-avn-border",
        "rounded-avn-xl shadow-avn-md",
        "animate-scale-in",
        "flex flex-col max-h-[90vh]",
        size_class(@size),
        @class
      ])}>

        <%# Header %>
        <%= if @title != [] or @description != [] do %>
          <div class="flex items-start justify-between gap-4 px-6 py-5 border-b border-avn-border shrink-0">
            <div>
              <%= if @title != [] do %>
                <h2
                  id={"#{@id}-title"}
                  class="text-base font-medium text-avn-foreground leading-tight"
                >
                  <%= render_slot(@title) %>
                </h2>
              <% end %>
              <%= if @description != [] do %>
                <p class="mt-1 text-sm text-avn-muted-foreground">
                  <%= render_slot(@description) %>
                </p>
              <% end %>
            </div>
            <%# Close button %>
            <button
              type="button"
              phx-click={@on_close}
              class="shrink-0 rounded-elx p-1.5 text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted transition-colors"
              aria-label="Close"
            >
              <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
        <% end %>

        <%# Body — scrollable %>
        <div class="flex-1 overflow-y-auto px-6 py-5 min-h-0">
          <%= render_slot(@inner_block) %>
        </div>

        <%# Footer %>
        <%= if @footer != [] do %>
          <div class="flex items-center justify-end gap-2 px-6 py-4 border-t border-avn-border bg-avn-muted/40 rounded-b-avn-xl shrink-0">
            <%= render_slot(@footer) %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc "JS command to hide a modal with exit animation before unmount."
  def hide_modal(id) do
    %JS{}
    |> JS.add_class("opacity-0 scale-95",
        to: "##{id} [role='dialog'] > div:last-child",
        transition: "ease-in duration-150"
    )
    |> JS.add_class("opacity-0",
        to: "##{id} > div:first-child",
        transition: "ease-in duration-150"
    )
  end

  defp size_class(size), do: @size_classes[size]
end
