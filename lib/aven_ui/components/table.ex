defmodule AvenUI.Components.Table do
  @moduledoc """
  Data table component with sortable columns, striping, and LiveView pagination.

  Designed for high-performance rendering — uses `stream` and `stream_insert`
  compatible row slots. Columns are declared with named slots; sort state
  is managed by the parent LiveView.

  ## Examples

      <%# Basic usage %>
      <.table rows={@deployments}>
        <:col :let={row} label="Commit">
          <code class="text-xs font-mono"><%= row.sha %></code>
        </:col>
        <:col :let={row} label="Branch"><%= row.branch %></:col>
        <:col :let={row} label="Status">
          <.badge variant={status_variant(row.status)}><%= row.status %></.badge>
        </:col>
        <:action :let={row}>
          <.button variant="ghost" size="xs" phx-click="restart" phx-value-id={row.id}>
            Restart
          </.button>
        </:action>
      </.table>

      <%# With sorting — pass sort_field and sort_dir to enable sort headers %>
      <.table rows={@users} sort_field={@sort_field} sort_dir={@sort_dir}>
        <:col :let={user} label="Name" field="name" sortable>
          <div class="flex items-center gap-2">
            <.avatar initials={initials(user.name)} size="sm" />
            <%= user.name %>
          </div>
        </:col>
        <:col :let={user} label="Joined" field="inserted_at" sortable>
          <%= Calendar.strftime(user.inserted_at, "%b %d, %Y") %>
        </:col>
      </.table>

      <%# With LiveView streams (phx-update="stream") %>
      <.table id="deployments-table" rows={@streams.deployments} stream>
        <:col :let={{id, row}} label="ID"><%= id %></:col>
        <:col :let={{_id, row}} label="Branch"><%= row.branch %></:col>
      </.table>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :id,         :string,  default: nil
  attr :rows,       :list,    required: true
  attr :stream,     :boolean, default: false, doc: "Enable phx-update='stream' on tbody"
  attr :sort_field, :string,  default: nil,   doc: "Currently sorted field name"
  attr :sort_dir,   :string,  default: "asc", values: ~w(asc desc)
  attr :striped,    :boolean, default: false
  attr :class,      :string,  default: nil

  slot :col, required: true do
    attr :label,    :string
    attr :field,    :string, doc: "Field name for sorting"
    attr :sortable, :boolean
    attr :class,    :string
    attr :align,    :string, values: ~w(left center right)
  end

  slot :action, doc: "Action cell rendered at the far right of each row"
  slot :empty,  doc: "Content shown when rows is empty"

  def table(assigns) do
    ~H"""
    <div class={classes(["w-full overflow-x-auto", @class])}>
      <table class="w-full text-sm border-collapse">
        <thead>
          <tr class="border-b border-avn-border">
            <%= for col <- @col do %>
              <th
                scope="col"
                class={classes([
                  "px-4 py-2.5 text-left font-medium text-avn-muted-foreground whitespace-nowrap text-xs uppercase tracking-wide",
                  align_class(col[:align]),
                  if(col[:sortable], do: "cursor-pointer hover:text-avn-foreground select-none"),
                  col[:class]
                ])}
                phx-click={if col[:sortable] && col[:field], do: "sort"}
                phx-value-field={col[:field]}
              >
                <span class="inline-flex items-center gap-1">
                  <%= col[:label] %>
                  <%= if col[:sortable] && col[:field] do %>
                    <%= sort_icon(col[:field], @sort_field, @sort_dir) %>
                  <% end %>
                </span>
              </th>
            <% end %>
            <%= if @action != [] do %>
              <th class="px-4 py-2.5 text-right text-xs font-medium text-avn-muted-foreground uppercase tracking-wide">
                Actions
              </th>
            <% end %>
          </tr>
        </thead>

        <tbody
          id={@id}
          phx-update={if @stream, do: "stream"}
          class="divide-y divide-avn-border"
        >
          <%= if Enum.empty?(@rows) do %>
            <tr>
              <td
                colspan={length(@col) + if(@action != [], do: 1, else: 0)}
                class="px-4 py-12 text-center text-sm text-avn-muted-foreground"
              >
                <%= if @empty != [] do %>
                  <%= render_slot(@empty) %>
                <% else %>
                  No results found.
                <% end %>
              </td>
            </tr>
          <% else %>
            <%= for row <- @rows do %>
              <tr class={classes([
                "group",
                if(@striped, do: "even:bg-avn-muted/30"),
                "hover:bg-avn-muted/50 transition-colors duration-100"
              ])}>
                <%= for col <- @col do %>
                  <td class={classes(["px-4 py-3 align-middle", align_class(col[:align]), col[:class]])}>
                    <%= render_slot(col, row) %>
                  </td>
                <% end %>
                <%= if @action != [] do %>
                  <td class="px-4 py-2 text-right">
                    <div class="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
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
    """
  end

  @doc """
  Pagination component — pairs with the table for server-side paging.

  ## Example

      <.pagination
        page={@page}
        total_pages={@total_pages}
        phx-click="paginate"
      />
  """
  attr :page,        :integer, required: true
  attr :total_pages, :integer, required: true
  attr :class,       :string,  default: nil
  attr :rest,        :global,  include: ~w(phx-click phx-target)

  def pagination(assigns) do
    ~H"""
    <div class={classes(["flex items-center justify-between gap-4 px-1", @class])}>
      <p class="text-sm text-avn-muted-foreground">
        Page <span class="font-medium text-avn-foreground"><%= @page %></span>
        of <span class="font-medium text-avn-foreground"><%= @total_pages %></span>
      </p>

      <div class="flex items-center gap-1">
        <button
          type="button"
          disabled={@page <= 1}
          class="inline-flex items-center justify-center h-8 w-8 rounded-elx border border-avn-border text-sm hover:bg-avn-muted disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
          phx-value-page={@page - 1}
          {@rest}
          aria-label="Previous page"
        >
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/>
          </svg>
        </button>

        <%= for page_num <- page_range(@page, @total_pages) do %>
          <%= if page_num == :ellipsis do %>
            <span class="h-8 w-8 flex items-center justify-center text-sm text-avn-muted-foreground">…</span>
          <% else %>
            <button
              type="button"
              class={classes([
                "h-8 w-8 rounded-elx border text-sm transition-colors",
                if(page_num == @page,
                  do: "bg-avn-purple text-white border-avn-purple",
                  else: "border-avn-border hover:bg-avn-muted"
                )
              ])}
              phx-value-page={page_num}
              {@rest}
            >
              <%= page_num %>
            </button>
          <% end %>
        <% end %>

        <button
          type="button"
          disabled={@page >= @total_pages}
          class="inline-flex items-center justify-center h-8 w-8 rounded-elx border border-avn-border text-sm hover:bg-avn-muted disabled:opacity-40 disabled:cursor-not-allowed transition-colors"
          phx-value-page={@page + 1}
          {@rest}
          aria-label="Next page"
        >
          <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/>
          </svg>
        </button>
      </div>
    </div>
    """
  end

  # Private helpers

  defp sort_icon(field, sort_field, sort_dir) when field == sort_field do
    case sort_dir do
      "asc" ->
        Phoenix.HTML.raw("""
        <svg class="h-3 w-3 text-avn-purple" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M5 15l7-7 7 7"/>
        </svg>
        """)
      _ ->
        Phoenix.HTML.raw("""
        <svg class="h-3 w-3 text-avn-purple" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
        </svg>
        """)
    end
  end

  defp sort_icon(_, _, _) do
    Phoenix.HTML.raw("""
    <svg class="h-3 w-3 opacity-30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
      <path stroke-linecap="round" stroke-linejoin="round" d="M7 16V4m0 0L3 8m4-4l4 4M17 8v12m0 0l4-4m-4 4l-4-4"/>
    </svg>
    """)
  end

  defp align_class("center"), do: "text-center"
  defp align_class("right"),  do: "text-right"
  defp align_class(_),        do: "text-left"

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
