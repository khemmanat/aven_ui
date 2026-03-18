defmodule AvenUI.Components.Input do
  @moduledoc """
  Form input components: text fields, selects, textareas, and search inputs.
  Designed to work seamlessly with `Phoenix.HTML.Form` and `Ecto.Changeset`.

  ## Features

  - Consistent sizing and border tokens
  - Error state driven by `Phoenix.HTML.Form` field errors
  - Label, hint, and error message composable slots
  - Prefix/suffix icon support
  - Native integration with `phx-change` and `phx-debounce`

  ## Examples

      <%# Basic usage with a changeset form %>
      <.input field={@form[:email]} type="email" label="Email address" />

      <%# With hint text %>
      <.input field={@form[:username]} label="Username" hint="Letters and numbers only" />

      <%# Password with show/hide toggle (uses the Toggle hook) %>
      <.input field={@form[:password]} type="password" label="Password" />

      <%# Search input %>
      <.input type="search" name="q" value={@query} placeholder="Search…" phx-change="search" phx-debounce="200" />

      <%# With prefix icon %>
      <.input field={@form[:amount]} type="number" label="Amount">
        <:prefix>฿</:prefix>
      </.input>

      <%# Standalone (no form) %>
      <.input type="text" name="tag" id="tag-input" value="" placeholder="Add tag…" />
  """

  use Phoenix.Component
  import AvenUI.Helpers

  alias Phoenix.HTML.Form

  @base_input_classes """
  flex w-full rounded-elx border border-avn-border bg-avn-background
  px-3 py-2 text-sm text-avn-foreground
  placeholder:text-avn-muted-foreground
  focus:outline-none focus:ring-2 focus:ring-avn-purple focus:border-transparent
  disabled:cursor-not-allowed disabled:opacity-50
  transition-colors duration-150
  """

  @error_classes "border-red-400 focus:ring-red-500 dark:border-red-600"

  attr :id,          :any,     default: nil
  attr :name,        :any,     default: nil
  attr :value,       :any,     default: nil
  attr :type,        :string,  default: "text",
    values: ~w(text email password search number tel url textarea)
  attr :label,       :string,  default: nil
  attr :hint,        :string,  default: nil
  attr :placeholder, :string,  default: nil
  attr :required,    :boolean, default: false
  attr :disabled,    :boolean, default: false
  attr :class,       :string,  default: nil
  attr :field,       Phoenix.HTML.FormField, doc: "A %Phoenix.HTML.FormField{} — binds id, name, value, errors automatically."
  attr :rest,        :global,  include: ~w(phx-change phx-blur phx-focus phx-debounce autocomplete min max step pattern readonly)

  slot :prefix, doc: "Content rendered inside the input on the left (icon or text like '฿', '@')"
  slot :suffix, doc: "Content rendered inside the input on the right (clear button, unit label)"
  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, assigns.name || field.name)
    |> assign(:value, assigns.value || field.value)
    |> assign(:errors, Enum.map(field.errors, &translate_error/1))
    |> input()
  end

  def input(assigns) do
    assigns = assign_new(assigns, :errors, fn -> [] end)

    ~H"""
    <div class="w-full space-y-1.5">
      <%= if @label do %>
        <label for={@id || @name} class="block text-sm font-medium text-avn-foreground">
          <%= @label %>
          <%= if @required do %>
            <span class="text-red-500 ml-0.5" aria-hidden="true">*</span>
          <% end %>
        </label>
      <% end %>

      <div class="relative flex items-center">
        <%= if @prefix != [] do %>
          <span class="absolute left-3 text-sm text-avn-muted-foreground select-none pointer-events-none">
            <%= render_slot(@prefix) %>
          </span>
        <% end %>

        <%= if @type == "textarea" do %>
          <textarea
            id={@id || @name}
            name={@name}
            placeholder={@placeholder}
            disabled={@disabled}
            class={classes([
              String.trim(@base_input_classes),
              "min-h-[80px] resize-y",
              if(@prefix != [], do: "pl-8"),
              if(@suffix != [], do: "pr-8"),
              if(@errors != [], do: @error_classes),
              @class
            ])}
            aria-describedby={hint_id(@id || @name, @hint)}
            aria-invalid={if @errors != [], do: "true"}
            {@rest}
          ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
        <% else %>
          <input
            id={@id || @name}
            name={@name}
            type={@type}
            value={Phoenix.HTML.Form.normalize_value(@type, @value)}
            placeholder={@placeholder}
            disabled={@disabled}
            required={@required}
            class={classes([
              String.trim(@base_input_classes),
              "h-9",
              if(@prefix != [], do: "pl-8"),
              if(@suffix != [], do: "pr-8"),
              if(@errors != [], do: @error_classes),
              @class
            ])}
            aria-describedby={hint_id(@id || @name, @hint)}
            aria-invalid={if @errors != [], do: "true"}
            {@rest}
          />
        <% end %>

        <%= if @suffix != [] do %>
          <span class="absolute right-3 text-sm text-avn-muted-foreground">
            <%= render_slot(@suffix) %>
          </span>
        <% end %>
      </div>

      <%= if @hint && @errors == [] do %>
        <p id={hint_id(@id || @name, @hint)} class="text-xs text-avn-muted-foreground">
          <%= @hint %>
        </p>
      <% end %>

      <%= for error <- @errors do %>
        <p class="flex items-center gap-1 text-xs text-red-600 dark:text-red-400">
          <svg class="h-3 w-3 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <%= error %>
        </p>
      <% end %>
    </div>
    """
  end

  @doc """
  Select dropdown — wraps `<select>` with consistent styling.

  ## Example

      <.select field={@form[:region]} label="Region" options={["Bangkok", "Singapore", "Tokyo"]} />

      <.select name="status" label="Status" options={[{"Active", "active"}, {"Inactive", "inactive"}]} value={@filter} />
  """
  attr :id,      :any,    default: nil
  attr :name,    :any,    default: nil
  attr :value,   :any,    default: nil
  attr :label,   :string, default: nil
  attr :hint,    :string, default: nil
  attr :options, :list,   required: true
  attr :prompt,  :string, default: nil, doc: "Placeholder option (empty value)"
  attr :field,   Phoenix.HTML.FormField, doc: "Binds from a Phoenix form field"
  attr :class,   :string, default: nil
  attr :rest,    :global, include: ~w(phx-change phx-blur disabled required)

  def select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, assigns.name || field.name)
    |> assign(:value, assigns.value || field.value)
    |> assign(:errors, Enum.map(field.errors, &translate_error/1))
    |> select()
  end

  def select(assigns) do
    assigns = assign_new(assigns, :errors, fn -> [] end)

    ~H"""
    <div class="w-full space-y-1.5">
      <%= if @label do %>
        <label for={@id || @name} class="block text-sm font-medium text-avn-foreground">
          <%= @label %>
        </label>
      <% end %>

      <div class="relative">
        <select
          id={@id || @name}
          name={@name}
          class={classes([
            String.trim(@base_input_classes),
            "h-9 pr-8 appearance-none cursor-pointer",
            if(@errors != [], do: @error_classes),
            @class
          ])}
          {@rest}
        >
          <%= if @prompt do %>
            <option value=""><%= @prompt %></option>
          <% end %>
          <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
        </select>
        <%# Chevron icon %>
        <div class="pointer-events-none absolute inset-y-0 right-2 flex items-center">
          <svg class="h-4 w-4 text-avn-muted-foreground" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
          </svg>
        </div>
      </div>

      <%= for error <- @errors do %>
        <p class="text-xs text-red-600 dark:text-red-400"><%= error %></p>
      <% end %>
    </div>
    """
  end

  # Helpers
  defp hint_id(_name, nil), do: nil
  defp hint_id(name, _hint), do: "#{name}-hint"

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  defp translate_error(msg) when is_binary(msg), do: msg
end
