defmodule AvenUI.Components.Toggle do
  @moduledoc """
  Toggle switch component — accessible boolean input.

  Renders as a styled checkbox that looks like a native iOS/Android switch.
  Works with `phx-change` for real-time LiveView updates.

  ## Examples

      <.toggle name="dark_mode" checked={@settings.dark_mode} label="Dark mode" />

      <.toggle
        field={@form[:notifications]}
        label="Email notifications"
        hint="Receive updates via email"
      />

      <.toggle name="enabled" checked={false} label="Auto-deploy" size="lg" />
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :id,      :any,     default: nil
  attr :name,    :any,     default: nil
  attr :value,   :any,     default: "true"
  attr :checked, :boolean, default: false
  attr :label,   :string,  default: nil
  attr :hint,    :string,  default: nil
  attr :size,    :string,  default: "md", values: ~w(sm md lg)
  attr :class,   :string,  default: nil
  attr :field,   Phoenix.HTML.FormField, doc: "Binds from a Phoenix form field"
  attr :rest,    :global,  include: ~w(phx-change phx-blur disabled)

  def toggle(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, assigns.name || field.name)
    |> assign(:checked, Phoenix.HTML.Form.normalize_value("checkbox", field.value))
    |> toggle()
  end

  def toggle(assigns) do
    ~H"""
    <label class={classes(["inline-flex items-start gap-3 cursor-pointer group", @class])}>
      <div class="relative mt-0.5 shrink-0">
        <input
          type="checkbox"
          id={@id || @name}
          name={@name}
          value={@value}
          checked={@checked}
          class="sr-only peer"
          {@rest}
        />
        <div class={classes([
          "rounded-full border transition-colors duration-200",
          "bg-avn-border border-avn-border",
          "peer-checked:bg-avn-purple peer-checked:border-avn-purple",
          "peer-focus-visible:ring-2 peer-focus-visible:ring-avn-purple peer-focus-visible:ring-offset-2",
          "peer-disabled:opacity-50 peer-disabled:cursor-not-allowed",
          track_size(@size)
        ])} />
        <div class={classes([
          "absolute top-0.5 left-0.5 rounded-full bg-white shadow-sm",
          "transition-transform duration-200",
          "peer-checked:translate-x-full",
          thumb_size(@size)
        ])} />
      </div>

      <%= if @label || @hint do %>
        <div class="-mt-0.5">
          <%= if @label do %>
            <span class="text-sm font-medium text-avn-foreground block leading-tight"><%= @label %></span>
          <% end %>
          <%= if @hint do %>
            <span class="text-xs text-avn-muted-foreground mt-0.5 block"><%= @hint %></span>
          <% end %>
        </div>
      <% end %>
    </label>
    """
  end

  defp track_size("sm"), do: "h-4 w-7"
  defp track_size("md"), do: "h-5 w-9"
  defp track_size("lg"), do: "h-6 w-11"
  defp track_size(_),    do: "h-5 w-9"

  defp thumb_size("sm"), do: "h-3 w-3"
  defp thumb_size("md"), do: "h-4 w-4"
  defp thumb_size("lg"), do: "h-5 w-5"
  defp thumb_size(_),    do: "h-4 w-4"
end
