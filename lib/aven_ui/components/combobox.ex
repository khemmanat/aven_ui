defmodule AvenUI.Components.Combobox do
  @moduledoc """
  Combobox — searchable select input.

  Filtering happens server-side via `phx-change` on the search input.
  Open/close state is managed by a lightweight JS hook (`AvenUICombobox`).
  Works as a drop-in replacement for a plain `<select>` in any LiveView form.

  ## Examples

      <%# Basic — static options %>
      <.combobox
        id="country"
        name="country"
        placeholder="Search countries…"
        options={[
          %{value: "th", label: "Thailand"},
          %{value: "sg", label: "Singapore"},
          %{value: "jp", label: "Japan"},
        ]}
        selected={@selected_country}
      />

      <%# With live search — filter on server %>
      <.combobox
        id="user-search"
        name="user_id"
        placeholder="Search users…"
        options={@filtered_users}
        selected={@selected_user}
        on_search="search_users"
      />

      <%# With Phoenix form field %>
      <.combobox
        id="role"
        field={@form[:role]}
        placeholder="Select role…"
        options={[
          %{value: "admin", label: "Admin"},
          %{value: "editor", label: "Editor"},
          %{value: "viewer", label: "Viewer"},
        ]}
      />

  ## Handle server-side search

      def handle_event("search_users", %{"query" => query}, socket) do
        users = Accounts.search_users(query)
        {:noreply, assign(socket, :filtered_users, users)}
      end

  ## Option format

  Options can be a list of maps:

      %{value: "th", label: "Thailand"}
      %{value: "th", label: "Thailand", disabled: true}

  Or a list of `{label, value}` tuples:

      [{"Thailand", "th"}, {"Singapore", "sg"}]
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @doc "Searchable combobox — drop-in replacement for a select field."
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:options, :list, default: [])
  attr(:selected, :any, default: nil)
  attr(:placeholder, :string, default: "Search…")
  attr(:on_search, :string, default: nil, doc: "phx-change event name for server-side filtering")
  attr(:disabled, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:label, :string, default: nil)
  attr(:hint, :string, default: nil)
  attr(:error, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def combobox(assigns) do
    assigns = prepare_assigns(assigns)

    ~H"""
    <div class={classes(["relative w-full", @class])}>
      <%# Label %>
      <label :if={@label} for={"#{@id}-input"} class="block text-sm font-medium text-avn-foreground mb-1.5">
        <%= @label %>
        <span :if={@required} class="text-red-500 ml-0.5">*</span>
      </label>

      <%# Combobox wrapper — hook manages open/close/keyboard %>
      <div
        id={@id}
        phx-hook="AvenUICombobox"
        data-value={selected_value(@selected)}
        class="relative"
      >
        <%# Hidden input — submits the selected value with the form %>
        <input
          type="hidden"
          name={@name}
          id={"#{@id}-value"}
          value={selected_value(@selected)}
        />

        <%# Trigger button — shows selected label or placeholder %>
        <button
          type="button"
          id={"#{@id}-trigger"}
          disabled={@disabled}
          aria-haspopup="listbox"
          aria-expanded="false"
          aria-controls={"#{@id}-listbox"}
          class={classes([
            "w-full flex items-center justify-between gap-2",
            "px-3 h-9 rounded-avn border text-sm text-left",
            "transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple",
            if(@disabled,
              do: "bg-avn-muted text-avn-muted-foreground border-avn-border cursor-not-allowed opacity-60",
              else: "bg-avn-background text-avn-foreground border-avn-border hover:border-avn-purple cursor-pointer"
            ),
            if(@error, do: "border-red-500", else: "border-avn-border")
          ])}
        >
          <span id={"#{@id}-display"} class={classes([
            "truncate",
            if(is_nil(@selected), do: "text-avn-muted-foreground", else: "text-avn-foreground")
          ])}>
            <%= selected_label(@selected, @options) || @placeholder %>
          </span>
          <%# Chevron icon %>
          <svg
            class="w-4 h-4 text-avn-muted-foreground shrink-0 transition-transform duration-150"
            id={"#{@id}-chevron"}
            viewBox="0 0 24 24" fill="none" stroke="currentColor"
            stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
          >
            <path d="M6 9l6 6 6-6"/>
          </svg>
        </button>

        <%# Dropdown panel %>
        <div
          id={"#{@id}-panel"}
          role="dialog"
          aria-label={"#{@label || "Select"} options"}
          class="hidden absolute z-50 w-full mt-1 rounded-avn-lg border border-avn-border bg-avn-background shadow-avn-md overflow-hidden"
        >
          <%# Search input %>
          <div class="p-2 border-b border-avn-border">
            <div class="relative">
              <svg class="absolute left-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-avn-muted-foreground"
                viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>
              </svg>
              <input
                type="text"
                id={"#{@id}-input"}
                placeholder={@placeholder}
                autocomplete="off"
                phx-change={@on_search}
                phx-debounce="200"
                name="query"
                class="w-full pl-8 pr-3 py-1.5 text-sm bg-avn-muted rounded border-0 outline-none
                       text-avn-foreground placeholder:text-avn-muted-foreground
                       focus:ring-1 focus:ring-avn-purple"
              />
            </div>
          </div>

          <%# Options list %>
          <ul
            id={"#{@id}-listbox"}
            role="listbox"
            aria-label={@label || "Options"}
            class="max-h-56 overflow-y-auto py-1"
          >
            <%# Empty state %>
            <li
              id={"#{@id}-empty"}
              class={classes([
                "px-3 py-6 text-sm text-avn-muted-foreground text-center",
                if(Enum.empty?(@options), do: "block", else: "hidden")
              ])}
            >
              No results found
            </li>

            <%# Option items %>
            <li
              :for={opt <- normalize_options(@options)}
              id={"#{@id}-opt-#{opt.value}"}
              role="option"
              aria-selected={to_string(selected_value(@selected) == to_string(opt.value))}
              aria-disabled={to_string(opt[:disabled] || false)}
              data-value={opt.value}
              data-label={opt.label}
              class={classes([
                "relative flex items-center gap-2 px-3 py-2 text-sm cursor-pointer select-none",
                "transition-colors",
                if(opt[:disabled],
                  do: "text-avn-muted-foreground cursor-not-allowed opacity-50",
                  else: "text-avn-foreground hover:bg-avn-muted"
                )
              ])}
            >
              <%# Checkmark for selected %>
              <svg
                class={classes([
                  "w-3.5 h-3.5 shrink-0 text-avn-purple",
                  if(selected_value(@selected) == to_string(opt.value), do: "opacity-100", else: "opacity-0")
                ])}
                viewBox="0 0 24 24" fill="none" stroke="currentColor"
                stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"
              >
                <path d="M20 6L9 17l-5-5"/>
              </svg>
              <span class="truncate"><%= opt.label %></span>
            </li>
          </ul>
        </div>
      </div>

      <%# Hint %>
      <p :if={@hint && !@error} class="mt-1 text-xs text-avn-muted-foreground">
        <%= @hint %>
      </p>

      <%# Error %>
      <p :if={@error} class="mt-1 text-xs text-red-500 flex items-center gap-1">
        <svg class="w-3 h-3 shrink-0" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
        </svg>
        <%= @error %>
      </p>
    </div>
    """
  end

  # ── Helpers ──────────────────────────────────────────────────────────

  defp prepare_assigns(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(:name, field.name)
    |> assign(:selected, field.value)
    |> assign(:error, field.errors |> List.first() |> format_error())
    |> assign(:id, assigns[:id] || field.id)
  end

  defp prepare_assigns(assigns), do: assign_new(assigns, :error, fn -> nil end)

  defp normalize_options(options) when is_list(options) do
    Enum.map(options, fn
      %{value: _, label: _} = opt -> opt
      {label, value} -> %{value: value, label: label}
      value -> %{value: value, label: to_string(value)}
    end)
  end

  defp selected_value(nil), do: ""
  defp selected_value(%{value: v}), do: to_string(v)
  defp selected_value(v) when is_binary(v), do: v
  defp selected_value(v), do: to_string(v)

  defp selected_label(nil, _options), do: nil

  defp selected_label(selected, options) do
    val = selected_value(selected)

    options
    |> normalize_options()
    |> Enum.find(&(to_string(&1.value) == val))
    |> case do
      %{label: label} -> label
      nil -> nil
    end
  end

  defp format_error(nil), do: nil
  defp format_error({msg, _opts}), do: msg
  defp format_error(msg), do: msg
end
