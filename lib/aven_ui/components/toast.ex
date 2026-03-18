defmodule AvenUI.Components.Toast do
  @moduledoc """
  Toast notification system for Phoenix LiveView.

  ## Two usage patterns

  ### 1. Phoenix Flash (recommended for server events)

  Use the `flash_group/1` component to render Phoenix flash messages.
  Phoenix handles the lifecycle; AvenUI handles the visual presentation.

      <%# In your root layout (root.html.heex) %>
      <.flash_group flash={@flash} />

  Send from LiveView:

      socket |> put_flash(:info,    "Settings saved.")
      socket |> put_flash(:success, "Deployment complete!")
      socket |> put_flash(:warning, "Memory pressure detected.")
      socket |> put_flash(:error,   "Connection failed.")

  ### 2. PubSub-pushed toasts (for background jobs, real-time events)

  Use `ToastLive` embedded in your layout — subscribes to a PubSub topic
  and renders toasts as they arrive.

      # In your app layout:
      # <.live_component module={AvenUI.Components.ToastLive}
      #   id="global-toasts"
      #   topic={"user:" <> to_string(@current_user.id)}
      # />

  Send from anywhere:

      AvenUI.Toast.push(user_id, :success, "Build #42 passed ✓")
      AvenUI.Toast.push(user_id, :error,   "Deploy failed: timeout")

  ## Standalone toast

      <.toast variant="success" title="Saved!" phx-hook="Flash" id="t1">
        Your changes have been saved.
      </.toast>
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import AvenUI.Helpers

  @variant_classes %{
    "info"    => "border-blue-200  bg-avn-card [&_.toast-icon]:text-blue-500",
    "success" => "border-green-200 bg-avn-card [&_.toast-icon]:text-green-500",
    "warning" => "border-amber-200 bg-avn-card [&_.toast-icon]:text-amber-500",
    "error"   => "border-red-200   bg-avn-card [&_.toast-icon]:text-red-500",
  }

  @icons %{
    "info"    => "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
    "success" => "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z",
    "warning" => "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z",
    "error"   => "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z",
  }

  attr :id,         :string,  required: true
  attr :variant,    :string,  default: "info",  values: ~w(info success warning error)
  attr :title,      :string,  default: nil
  attr :duration,   :integer, default: 4000,    doc: "Auto-dismiss in ms (0 = no auto-dismiss)"
  attr :dismissible,:boolean, default: true
  attr :class,      :string,  default: nil
  attr :rest,       :global

  slot :inner_block

  def toast(assigns) do
    ~H"""
    <div
      id={@id}
      role="status"
      aria-live="polite"
      phx-hook="Flash"
      data-duration={@duration}
      class={classes([
        "flex items-start gap-3 w-full max-w-sm rounded-avn-lg border p-4",
        "shadow-avn-md pointer-events-auto",
        "transition-all duration-200",
        variant_class(@variant),
        @class
      ])}
      {@rest}
    >
      <%# Icon %>
      <div class="toast-icon shrink-0 mt-0.5">
        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d={icon(@variant)} />
        </svg>
      </div>

      <%# Content %>
      <div class="flex-1 min-w-0">
        <%= if @title do %>
          <p class="text-sm font-medium text-avn-foreground"><%= @title %></p>
        <% end %>
        <%= if @inner_block != [] do %>
          <p class="text-sm text-avn-muted-foreground mt-0.5 leading-relaxed">
            <%= render_slot(@inner_block) %>
          </p>
        <% end %>
      </div>

      <%# Dismiss %>
      <%= if @dismissible do %>
        <button
          type="button"
          phx-click={JS.hide(to: "##{@id}", transition: {"ease-in duration-150", "opacity-100 translate-y-0", "opacity-0 translate-y-1"})}
          class="shrink-0 ml-1 rounded p-1 text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted transition-colors"
          aria-label="Dismiss"
        >
          <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      <% end %>
    </div>
    """
  end

  @doc """
  Flash group — renders all Phoenix flash messages in a fixed toast container.
  Place once in your root layout.

  ## Example

      <%# lib/my_app_web/components/layouts/root.html.heex %>
      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "The @flash map from the socket/conn"
  attr :class, :string, default: nil

  def flash_group(assigns) do
    ~H"""
    <div
      class={classes([
        "fixed bottom-4 right-4 z-[var(--avn-z-toast)]",
        "flex flex-col gap-2 items-end",
        "pointer-events-none",
        @class
      ])}
      aria-label="Notifications"
    >
      <%# Render each flash type %>
      <.toast
        :if={msg = Phoenix.Flash.get(@flash, :info)}
        id="flash-info"
        variant="info"
        title="Info"
      >
        <%= msg %>
      </.toast>

      <.toast
        :if={msg = Phoenix.Flash.get(@flash, :success)}
        id="flash-success"
        variant="success"
        title="Success"
      >
        <%= msg %>
      </.toast>

      <.toast
        :if={msg = Phoenix.Flash.get(@flash, :warning)}
        id="flash-warning"
        variant="warning"
        title="Warning"
      >
        <%= msg %>
      </.toast>

      <.toast
        :if={msg = Phoenix.Flash.get(@flash, :error)}
        id="flash-error"
        variant="error"
        title="Error"
        duration={6000}
      >
        <%= msg %>
      </.toast>
    </div>
    """
  end

  @doc """
  Inline flash banner — full-width, used at the top of pages.

  ## Example

      <.flash_banner flash={@flash} />
  """
  attr :flash, :map, required: true
  attr :class, :string, default: nil

  def flash_banner(assigns) do
    ~H"""
    <%= for {kind, msg} <- @flash, msg do %>
      <div
        id={"flash-banner-#{kind}"}
        phx-hook="Flash"
        data-duration="5000"
        class={classes([
          "flex items-center justify-between gap-4 px-4 py-3 text-sm",
          banner_class(to_string(kind)),
          @class
        ])}
        role="alert"
      >
        <p class="flex-1"><%= msg %></p>
        <button
          type="button"
          phx-click={JS.hide(to: "#flash-banner-#{kind}")}
          class="shrink-0 rounded p-1 opacity-70 hover:opacity-100 transition-opacity"
          aria-label="Dismiss"
        >
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>
    <% end %>
    """
  end

  defp banner_class("success"), do: "bg-green-50 text-green-800 border-b border-green-200 dark:bg-green-950/40 dark:text-green-300 dark:border-green-800"
  defp banner_class("warning"), do: "bg-amber-50 text-amber-800 border-b border-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800"
  defp banner_class("error"),   do: "bg-red-50   text-red-800   border-b border-red-200   dark:bg-red-950/40   dark:text-red-300   dark:border-red-800"
  defp banner_class(_),         do: "bg-blue-50  text-blue-800  border-b border-blue-200  dark:bg-blue-950/40  dark:text-blue-300  dark:border-blue-800"

  defp variant_class(v), do: Map.get(@variant_classes, v, @variant_classes["info"])
  defp icon(v),          do: Map.get(@icons, v, @icons["info"])
end
