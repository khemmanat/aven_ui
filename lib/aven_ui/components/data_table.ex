defmodule AvenUI.Components.DataTable do
  @moduledoc """
  Rich data table with filter bar, server-side sort, and pagination.

  All filtering and sorting fires server-side `phx` events — the developer
  queries the database and updates the rows assign. This scales to any
  dataset size and integrates cleanly with Ecto.

  Use `AvenUI.DataTable` struct to manage state in your LiveView.

  ## Basic example

      <%!-- In the template --%>
      <.data_table
        id="users-table"
        rows={@rows}
        table={@table}
        on_filter="dt_filter"
        on_sort="dt_sort"
        on_paginate="dt_paginate"
      >
        <:filter>
          <.dt_search name="search" placeholder="Search users…" />
          <.dt_select name="status" prompt="All statuses"
            options={[{"Active", "active"}, {"Inactive", "inactive"}]} />
        </:filter>

        <:col :let={user} label="Name" field="name" sortable>
          <div class="flex items-center gap-2">
            <.avatar initials={String.first(user.name)} size="sm" />
            <span class="font-medium"><%= user.name %></span>
          </div>
        </:col>
        <:col :let={user} label="Email" field="email" sortable>
          <%= user.email %>
        </:col>
        <:col :let={user} label="Status">
          <.badge variant={if user.active, do: "success", else: "default"}>
            <%= if user.active, do: "Active", else: "Inactive" %>
          </.badge>
        </:col>
        <:col :let={user} label="Joined" field="inserted_at" sortable>
          <%= Calendar.strftime(user.inserted_at, "%b %d, %Y") %>
        </:col>

        <:action :let={user}>
          <.button size="xs" variant="ghost" phx-click="edit" phx-value-id={user.id}>
            Edit
          </.button>
          <.button size="xs" variant="ghost" phx-click="delete" phx-value-id={user.id}>
            Delete
          </.button>
        </:action>
      </.data_table>

  ## Required LiveView handlers

      alias AvenUI.DataTable

      def mount(_, _, socket) do
        {:ok,
         socket
         |> assign(:table, DataTable.new(per_page: 20))
         |> load_rows()}
      end

      def handle_event("dt_filter", params, socket) do
        table = socket.assigns.table
                |> DataTable.set_filter(params)
                |> DataTable.reset_page()
        {:noreply, socket |> assign(:table, table) |> load_rows()}
      end

      def handle_event("dt_sort", %{"field" => field}, socket) do
        table = DataTable.toggle_sort(socket.assigns.table, field)
        {:noreply, socket |> assign(:table, table) |> load_rows()}
      end

      def handle_event("dt_paginate", %{"page" => page}, socket) do
        table = DataTable.set_page(socket.assigns.table, String.to_integer(page))
        {:noreply, socket |> assign(:table, table) |> load_rows()}
      end

      defp load_rows(socket) do
        dt = socket.assigns.table
        {rows, total} = MyApp.Accounts.list_users(
          search:     DataTable.filter_value(dt, "search"),
          status:     DataTable.filter_value(dt, "status"),
          sort_field: dt.sort_field,
          sort_dir:   dt.sort_dir,
          limit:      dt.per_page,
          offset:     DataTable.offset(dt)
        )
        socket
        |> assign(:rows, rows)
        |> assign(:table, DataTable.put_total(dt, total))
      end
  """

  use Phoenix.Component
  import AvenUI.Helpers
  alias AvenUI.DataTable

  # ── Main data_table component ─────────────────────────────────────────

  @doc "Rich data table with filter bar, sort, and pagination."
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)
  attr(:table, :any, required: true, doc: "AvenUI.DataTable struct")
  attr(:on_filter, :string, default: "dt_filter", doc: "phx event for filter changes")
  attr(:on_sort, :string, default: "dt_sort", doc: "phx event for sort changes")
  attr(:on_paginate, :string, default: "dt_paginate", doc: "phx event for page changes")
  attr(:title, :string, default: nil)
  attr(:subtitle, :string, default: nil)
  attr(:striped, :boolean, default: false)
  attr(:class, :string, default: nil)

  slot(:filter, doc: "Filter bar content — use dt_search and dt_select inside")
  slot(:toolbar, doc: "Right side of the toolbar — buttons, export, etc.")

  slot :col, required: true do
    attr(:label, :string)
    attr(:field, :string, doc: "Field name — required for sortable columns")
    attr(:sortable, :boolean)
    attr(:class, :string)
    attr(:align, :string, values: ~w(left center right))
  end

  slot(:action, doc: "Action buttons — revealed on row hover")
  slot(:empty, doc: "Content shown when rows is empty")

  def data_table(assigns) do
    total_pages = DataTable.total_pages(assigns.table)
    assigns = assign(assigns, :total_pages, total_pages)

    ~H"""
    <div class={classes(["w-full space-y-0 rounded-avn-xl border border-avn-border overflow-hidden", @class])}>

      <%!-- ── Header ──────────────────────────────────────────────── --%>
      <div :if={@title || @filter != [] || @toolbar != []}
           class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 px-4 py-3 bg-avn-card border-b border-avn-border">

        <div :if={@title} class="min-w-0">
          <h3 class="text-sm font-semibold text-avn-foreground truncate"><%= @title %></h3>
          <p :if={@subtitle} class="text-xs text-avn-muted-foreground mt-0.5"><%= @subtitle %></p>
        </div>

        <%!-- Filter bar + toolbar --%>
        <div class="flex flex-wrap items-center gap-2 sm:ml-auto">
          <%!-- Filter controls — dt_search, dt_select, etc. --%>
          <%= if @filter != [] do %>
            <form
              phx-change={@on_filter}
              phx-debounce="300"
              class="flex flex-wrap items-center gap-2"
            >
              <%= render_slot(@filter) %>

              <%!-- Clear filters button — shown when any filter active --%>
              <button
                :if={DataTable.filtered?(@table)}
                type="button"
                phx-click={@on_filter}
                phx-value-_clear="true"
                class="flex items-center gap-1 px-2.5 h-8 text-xs text-avn-muted-foreground
                       border border-avn-border rounded-avn hover:text-avn-foreground
                       hover:bg-avn-muted transition-colors"
              >
                <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M18 6L6 18M6 6l12 12"/>
                </svg>
                Clear
              </button>
            </form>
          <% end %>

          <%!-- Toolbar slot — e.g. New button, Export --%>
          <%= if @toolbar != [] do %>
            <div class="flex items-center gap-2">
              <%= render_slot(@toolbar) %>
            </div>
          <% end %>
        </div>
      </div>

      <%!-- ── Active filter chips ──────────────────────────────────── --%>
      <div
        :if={DataTable.filtered?(@table)}
        class="flex flex-wrap gap-1.5 px-4 py-2 bg-avn-muted/40 border-b border-avn-border"
      >
        <span class="text-[10px] font-medium text-avn-muted-foreground uppercase tracking-wide self-center mr-1">
          Filters:
        </span>
        <%= for {key, val} <- @table.filter do %>
          <span class="inline-flex items-center gap-1 pl-2 pr-1 py-0.5 rounded-full text-xs
                       bg-avn-purple-100 text-avn-purple-800 border border-avn-purple-200
                       dark:bg-avn-purple-900/30 dark:text-avn-purple-300 dark:border-avn-purple-800">
            <span class="font-medium"><%= key %>:</span> <%= val %>
            <button
              type="button"
              phx-click={@on_filter}
              phx-value-_remove={key}
              class="ml-0.5 rounded-full hover:bg-avn-purple-200 dark:hover:bg-avn-purple-800/40 p-0.5 transition-colors"
              aria-label={"Remove #{key} filter"}
            >
              <svg class="w-2.5 h-2.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                <path d="M18 6L6 18M6 6l12 12"/>
              </svg>
            </button>
          </span>
        <% end %>
      </div>

      <%!-- ── Table ───────────────────────────────────────────────── --%>
      <div class="w-full overflow-x-auto">
        <table class="w-full text-sm border-collapse">
          <thead>
            <tr class="border-b border-avn-border bg-avn-muted/30">
              <%= for col <- @col do %>
                <th
                  scope="col"
                  class={classes([
                    "px-4 py-2.5 text-left font-medium text-avn-muted-foreground",
                    "whitespace-nowrap text-xs uppercase tracking-wide",
                    align_class(col[:align]),
                    if(col[:sortable], do: "cursor-pointer hover:text-avn-foreground select-none"),
                    col[:class]
                  ])}
                  phx-click={if col[:sortable] && col[:field], do: @on_sort}
                  phx-value-field={col[:field]}
                >
                  <span class="inline-flex items-center gap-1">
                    <%= col[:label] %>
                    <%= if col[:sortable] && col[:field] do %>
                      <%= sort_icon(col[:field], @table.sort_field, @table.sort_dir) %>
                    <% end %>
                  </span>
                </th>
              <% end %>
              <th :if={@action != []}
                  class="px-4 py-2.5 text-right text-xs font-medium text-avn-muted-foreground uppercase tracking-wide">
                Actions
              </th>
            </tr>
          </thead>

          <tbody class="divide-y divide-avn-border bg-avn-background">
            <%= if Enum.empty?(@rows) do %>
              <tr>
                <td
                  colspan={length(@col) + if(@action != [], do: 1, else: 0)}
                  class="px-4 py-16 text-center"
                >
                  <%= if @empty != [] do %>
                    <%= render_slot(@empty) %>
                  <% else %>
                    <div class="flex flex-col items-center gap-2">
                      <svg class="w-8 h-8 text-avn-muted-foreground opacity-40" viewBox="0 0 24 24"
                           fill="none" stroke="currentColor" stroke-width="1.5">
                        <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>
                      </svg>
                      <p class="text-sm text-avn-muted-foreground">
                        <%= if DataTable.filtered?(@table),
                          do: "No results match your filters.",
                          else: "No data yet." %>
                      </p>
                    </div>
                  <% end %>
                </td>
              </tr>
            <% else %>
              <%= for row <- @rows do %>
                <tr class={classes([
                  "group transition-colors duration-100",
                  if(@striped, do: "even:bg-avn-muted/20"),
                  "hover:bg-avn-muted/40"
                ])}>
                  <%= for col <- @col do %>
                    <td class={classes(["px-4 py-3 align-middle", align_class(col[:align]), col[:class]])}>
                      <%= render_slot(col, row) %>
                    </td>
                  <% end %>
                  <%= if @action != [] do %>
                    <td class="px-4 py-2 text-right">
                      <div class="flex items-center justify-end gap-1.5
                                  opacity-0 group-hover:opacity-100 transition-opacity">
                        <%= render_slot(@action, row) %>
                      </div>
                    </td>
                  <% end %>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>

      <%!-- ── Footer: count + pagination ─────────────────────────── --%>
      <div class="flex flex-col sm:flex-row items-center justify-between gap-3
                  px-4 py-3 border-t border-avn-border bg-avn-card">

        <%!-- Row count --%>
        <p class="text-xs text-avn-muted-foreground order-2 sm:order-1">
          <%= row_count_label(@table) %>
        </p>

        <%!-- Pagination --%>
        <div class="flex items-center gap-1 order-1 sm:order-2">
          <button
            type="button"
            disabled={@table.page <= 1}
            phx-click={@on_paginate}
            phx-value-page={@table.page - 1}
            class="h-8 w-8 flex items-center justify-center rounded-avn border border-avn-border
                   text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted
                   disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
            aria-label="Previous page"
          >
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M15 18l-6-6 6-6" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </button>

          <%= for p <- page_range(@table.page, @total_pages) do %>
            <%= if p == :ellipsis do %>
              <span class="h-8 w-8 flex items-center justify-center text-xs text-avn-muted-foreground">
                …
              </span>
            <% else %>
              <button
                type="button"
                phx-click={@on_paginate}
                phx-value-page={p}
                class={classes([
                  "h-8 w-8 flex items-center justify-center rounded-avn border text-xs transition-colors",
                  if(p == @table.page,
                    do: "bg-avn-purple text-white border-avn-purple font-medium",
                    else: "border-avn-border text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted"
                  )
                ])}
              >
                <%= p %>
              </button>
            <% end %>
          <% end %>

          <button
            type="button"
            disabled={@table.page >= @total_pages}
            phx-click={@on_paginate}
            phx-value-page={@table.page + 1}
            class="h-8 w-8 flex items-center justify-center rounded-avn border border-avn-border
                   text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted
                   disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
            aria-label="Next page"
          >
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 18l6-6-6-6" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </button>
        </div>
      </div>
    </div>
    """
  end

  # ── Filter sub-components ─────────────────────────────────────────────

  @doc "Search input for use inside the data_table :filter slot."
  attr(:name, :string, required: true)
  attr(:placeholder, :string, default: "Search…")
  attr(:value, :string, default: "")
  attr(:class, :string, default: nil)

  def dt_search(assigns) do
    ~H"""
    <div class={classes(["relative", @class])}>
      <svg class="absolute left-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-avn-muted-foreground pointer-events-none"
           viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/>
      </svg>
      <input
        type="text"
        name={@name}
        value={@value}
        placeholder={@placeholder}
        class="pl-8 pr-3 h-8 text-sm rounded-avn border border-avn-border bg-avn-background
               text-avn-foreground placeholder:text-avn-muted-foreground
               focus:outline-none focus:ring-2 focus:ring-avn-purple w-48"
      />
    </div>
    """
  end

  @doc "Select dropdown for use inside the data_table :filter slot."
  attr(:name, :string, required: true)
  attr(:options, :list, required: true, doc: "List of {label, value} tuples")
  attr(:prompt, :string, default: "All")
  attr(:value, :string, default: "")
  attr(:class, :string, default: nil)

  def dt_select(assigns) do
    ~H"""
    <div class={classes(["relative", @class])}>
      <select
        name={@name}
        class="h-8 pl-3 pr-7 text-sm rounded-avn border border-avn-border bg-avn-background
               text-avn-foreground appearance-none cursor-pointer
               focus:outline-none focus:ring-2 focus:ring-avn-purple"
      >
        <option value=""><%= @prompt %></option>
        <%= for {label, val} <- @options do %>
          <option value={val} selected={to_string(@value) == to_string(val)}>
            <%= label %>
          </option>
        <% end %>
      </select>
      <svg class="absolute right-2 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-avn-muted-foreground pointer-events-none"
           viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M6 9l6 6 6-6" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
    """
  end

  # ── Private helpers ───────────────────────────────────────────────────

  defp sort_icon(field, sort_field, sort_dir) when field == sort_field do
    case sort_dir do
      "asc" ->
        Phoenix.HTML.raw("""
        <svg class="h-3 w-3 text-avn-purple" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2.5" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M5 15l7-7 7 7"/>
        </svg>
        """)

      _ ->
        Phoenix.HTML.raw("""
        <svg class="h-3 w-3 text-avn-purple" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="2.5" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
        </svg>
        """)
    end
  end

  defp sort_icon(_, _, _) do
    Phoenix.HTML.raw("""
    <svg class="h-3 w-3 opacity-30" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" stroke-width="2" aria-hidden="true">
      <path stroke-linecap="round" stroke-linejoin="round" d="M7 16V4m0 0L3 8m4-4l4 4M17 8v12m0 0l4-4m-4 4l-4-4"/>
    </svg>
    """)
  end

  defp align_class("center"), do: "text-center"
  defp align_class("right"), do: "text-right"
  defp align_class(_), do: "text-left"

  defp row_count_label(%DataTable{total: 0}), do: "No results"

  defp row_count_label(%DataTable{page: page, per_page: per, total: total}) do
    first = (page - 1) * per + 1
    last = min(page * per, total)
    "Showing #{first}–#{last} of #{total}"
  end

  defp page_range(_current, total) when total <= 7 do
    Enum.to_list(1..total)
  end

  defp page_range(current, total) do
    cond do
      current <= 4 -> Enum.to_list(1..5) ++ [:ellipsis, total]
      current >= total - 3 -> [1, :ellipsis] ++ Enum.to_list((total - 4)..total)
      true -> [1, :ellipsis] ++ Enum.to_list((current - 1)..(current + 1)) ++ [:ellipsis, total]
    end
  end
end
