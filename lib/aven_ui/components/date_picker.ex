defmodule AvenUI.Components.DatePicker do
  @moduledoc """
  DatePicker — calendar-based date input for single dates and date ranges.

  The calendar grid is server-rendered. Navigation (prev/next month) sends
  LiveView events. Open/close is handled by the `AvenUIDatePicker` JS hook.
  No external date library required.

  ## Single date example

      <.date_picker
        id="birthday"
        name="birthday"
        label="Birthday"
        selected={@selected_date}
        on_change="date_selected"
      />

      # Handle in LiveView:
      def handle_event("date_selected", %{"date" => date_str}, socket) do
        date = Date.from_iso8601!(date_str)
        {:noreply, assign(socket, :selected_date, date)}
      end

  ## Date range example

      <.date_picker
        id="booking"
        name="booking"
        label="Stay dates"
        mode="range"
        range_start={@check_in}
        range_end={@check_out}
        on_change="dates_selected"
      />

      def handle_event("dates_selected", %{"start" => s, "end" => e}, socket) do
        {:noreply, assign(socket,
          check_in: Date.from_iso8601!(s),
          check_out: Date.from_iso8601!(e)
        )}
      end

  ## With Phoenix form field

      <.date_picker
        id="dob"
        field={@form[:date_of_birth]}
        label="Date of birth"
      />

  ## Navigation events

  Add these handlers to any LiveView that uses a date_picker:

      def handle_event("dp_prev_month_" <> id, _, socket) do
        socket = update(socket, :dp_month, &Date.beginning_of_month(Date.add(&1, -1)))
        {:noreply, socket}
      end

      def handle_event("dp_next_month_" <> id, _, socket) do
        socket = update(socket, :dp_month, &Date.beginning_of_month(Date.add(&1, 32)))
        {:noreply, socket}
      end
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @doc "Calendar date picker — single date or date range."
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:field, Phoenix.HTML.FormField, default: nil)
  attr(:label, :string, default: nil)
  attr(:hint, :string, default: nil)
  attr(:error, :string, default: nil)
  attr(:placeholder, :string, default: "Pick a date…")
  attr(:mode, :string, default: "single", doc: "single | range")
  attr(:selected, :any, default: nil, doc: "Date struct for single mode")
  attr(:range_start, :any, default: nil, doc: "Date struct — range start")
  attr(:range_end, :any, default: nil, doc: "Date struct — range end")
  attr(:view_month, :any, default: nil, doc: "Date struct — which month to display")
  attr(:min_date, :any, default: nil, doc: "Date struct — earliest selectable")
  attr(:max_date, :any, default: nil, doc: "Date struct — latest selectable")
  attr(:disabled, :boolean, default: false)
  attr(:required, :boolean, default: false)
  attr(:on_change, :string, default: "date_picked", doc: "phx event name on date select")
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def date_picker(assigns) do
    assigns = prepare_assigns(assigns)
    today = Date.utc_today()
    month = assigns.view_month || assigns.selected || today

    assigns =
      assigns
      |> assign(:today, today)
      |> assign(:month, Date.beginning_of_month(month))
      |> assign(:weeks, calendar_weeks(month))

    ~H"""
    <div class={classes(["relative w-full", @class])}>
      <%# Label %>
      <label :if={@label} for={"#{@id}-trigger"} class="block text-sm font-medium text-avn-foreground mb-1.5">
        <%= @label %>
        <span :if={@required} class="text-red-500 ml-0.5">*</span>
      </label>

      <%# Root — hook manages open/close %>
      <div id={@id} phx-hook="AvenUIDatePicker" class="relative">

        <%# Hidden inputs — submitted with form %>
        <%= if @mode == "range" do %>
          <input type="hidden" id={"#{@id}-start-val"} name={"#{@name}[start]"} value={format_date(@range_start)} />
          <input type="hidden" id={"#{@id}-end-val"}   name={"#{@name}[end]"}   value={format_date(@range_end)} />
        <% else %>
          <input type="hidden" id={"#{@id}-val"} name={@name} value={format_date(@selected)} />
        <% end %>

        <%# Trigger button %>
        <button
          type="button"
          id={"#{@id}-trigger"}
          disabled={@disabled}
          aria-haspopup="dialog"
          aria-expanded="false"
          class={classes([
            "w-full flex items-center gap-2 px-3 h-9 rounded-avn border text-sm text-left",
            "transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple",
            if(@disabled,
              do: "bg-avn-muted text-avn-muted-foreground border-avn-border cursor-not-allowed opacity-60",
              else: "bg-avn-background border-avn-border hover:border-avn-purple cursor-pointer"
            ),
            if(@error, do: "border-red-500", else: "")
          ])}
        >
          <%# Calendar icon %>
          <svg class="w-4 h-4 text-avn-muted-foreground shrink-0" viewBox="0 0 24 24"
               fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
            <rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/>
          </svg>
          <span class={classes([
            "flex-1 truncate",
            if(is_nil(@selected) && is_nil(@range_start),
              do: "text-avn-muted-foreground",
              else: "text-avn-foreground"
            )
          ])}>
            <%= display_label(@mode, @selected, @range_start, @range_end, @placeholder) %>
          </span>
          <%# Clear button — shown when value set %>
          <button
            :if={has_value?(@mode, @selected, @range_start)}
            type="button"
            id={"#{@id}-clear"}
            class="p-0.5 rounded hover:bg-avn-muted text-avn-muted-foreground hover:text-avn-foreground transition-colors"
            aria-label="Clear date"
          >
            <svg class="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <path d="M18 6L6 18M6 6l12 12"/>
            </svg>
          </button>
        </button>

        <%# Calendar panel %>
        <div
          id={"#{@id}-panel"}
          role="dialog"
          aria-label="Date picker"
          aria-modal="true"
          class="hidden absolute z-50 mt-1 rounded-avn-xl border border-avn-border bg-avn-background shadow-avn-md p-3 w-[280px]"
        >
          <%# Month navigation header %>
          <div class="flex items-center justify-between mb-3">
            <button
              type="button"
              phx-click={"dp_prev_month_#{@id}"}
              class="w-7 h-7 flex items-center justify-center rounded-avn hover:bg-avn-muted
                     text-avn-muted-foreground hover:text-avn-foreground transition-colors"
              aria-label="Previous month"
            >
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                <path d="M15 18l-6-6 6-6"/>
              </svg>
            </button>

            <span class="text-sm font-semibold text-avn-foreground">
              <%= Calendar.strftime(@month, "%B %Y") %>
            </span>

            <button
              type="button"
              phx-click={"dp_next_month_#{@id}"}
              class="w-7 h-7 flex items-center justify-center rounded-avn hover:bg-avn-muted
                     text-avn-muted-foreground hover:text-avn-foreground transition-colors"
              aria-label="Next month"
            >
              <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                <path d="M9 18l6-6-6-6"/>
              </svg>
            </button>
          </div>

          <%# Day labels %>
          <div class="grid grid-cols-7 mb-1">
            <span :for={day <- ~w(Su Mo Tu We Th Fr Sa)}
                  class="text-[10px] font-medium text-avn-muted-foreground text-center py-1">
              <%= day %>
            </span>
          </div>

          <%# Calendar grid %>
          <div class="grid grid-cols-7 gap-y-0.5" role="grid" aria-label={Calendar.strftime(@month, "%B %Y")}>
            <%= for week <- @weeks do %>
              <%= for day <- week do %>
                <%= if day do %>
                  <button
                    type="button"
                    phx-click={@on_change}
                    phx-value-date={Date.to_iso8601(day)}
                    phx-value-mode={@mode}
                    disabled={day_disabled?(day, @min_date, @max_date)}
                    aria-selected={to_string(day_selected?(day, @mode, @selected, @range_start, @range_end))}
                    aria-label={Calendar.strftime(day, "%B %d, %Y")}
                    class={day_classes(day, @month, @today, @mode, @selected, @range_start, @range_end, @min_date, @max_date)}
                  >
                    <%= day.day %>
                  </button>
                <% else %>
                  <span />
                <% end %>
              <% end %>
            <% end %>
          </div>

          <%# Footer — range mode shows selected range summary %>
          <div :if={@mode == "range" && (@range_start || @range_end)}
               class="mt-3 pt-3 border-t border-avn-border text-xs text-avn-muted-foreground flex justify-between">
            <span>
              <%= if @range_start, do: Calendar.strftime(@range_start, "%b %d"), else: "Start" %>
            </span>
            <span class="text-avn-muted-foreground">→</span>
            <span>
              <%= if @range_end, do: Calendar.strftime(@range_end, "%b %d"), else: "End" %>
            </span>
          </div>

          <%# Today button %>
          <div class="mt-2 flex justify-center">
            <button
              type="button"
              phx-click={@on_change}
              phx-value-date={Date.to_iso8601(@today)}
              phx-value-mode={@mode}
              class="text-xs text-avn-purple hover:text-avn-purple-dark font-medium transition-colors"
            >
              Today
            </button>
          </div>
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

  # ── Calendar helpers ──────────────────────────────────────────────────

  defp calendar_weeks(date) do
    first = Date.beginning_of_month(date)
    last = Date.end_of_month(date)
    # Day of week for first day (0 = Sunday)
    start_dow = day_of_week_sunday(first)

    # Pad start with nils
    days = (List.duplicate(nil, start_dow) ++ Date.range(first, last)) |> Enum.to_list()

    # Pad end to fill last week
    remainder = rem(length(days), 7)
    days = if remainder > 0, do: days ++ List.duplicate(nil, 7 - remainder), else: days

    Enum.chunk_every(days, 7)
  end

  defp day_of_week_sunday(date) do
    # Date.day_of_week returns 1=Mon..7=Sun, convert to 0=Sun..6=Sat
    case Date.day_of_week(date) do
      7 -> 0
      n -> n
    end
  end

  defp day_classes(day, month, today, mode, selected, range_start, range_end, min_date, max_date) do
    is_today = day == today
    is_selected = day_selected?(day, mode, selected, range_start, range_end)
    is_in_range = mode == "range" && in_range?(day, range_start, range_end)
    is_range_edge = mode == "range" && (day == range_start || day == range_end)
    is_other_month = day.month != month.month
    is_disabled = day_disabled?(day, min_date, max_date)

    classes([
      "relative w-8 h-8 text-xs rounded-avn flex items-center justify-center",
      "transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple",
      if(is_disabled,
        do: "text-avn-muted-foreground cursor-not-allowed opacity-40",
        else: "cursor-pointer"
      ),
      if(is_other_month && !is_selected && !is_in_range,
        do: "text-avn-muted-foreground opacity-40",
        else: ""
      ),
      cond do
        is_selected || is_range_edge ->
          "bg-avn-purple text-white font-semibold hover:bg-avn-purple-dark"

        is_in_range ->
          "bg-avn-purple-100 text-avn-purple-900 rounded-none hover:bg-avn-purple-200"

        is_today ->
          "border border-avn-purple text-avn-purple font-semibold hover:bg-avn-muted"

        !is_disabled ->
          "text-avn-foreground hover:bg-avn-muted"

        true ->
          ""
      end
    ])
  end

  defp day_selected?(day, "single", selected, _, _), do: day == selected

  defp day_selected?(day, "range", _, start, ending),
    do: day == start || day == ending

  defp day_selected?(_, _, _, _, _), do: false

  defp in_range?(_day, nil, _), do: false
  defp in_range?(_day, _, nil), do: false

  defp in_range?(day, start, ending) when start <= ending,
    do: Date.compare(day, start) == :gt && Date.compare(day, ending) == :lt

  defp in_range?(day, start, ending),
    do: Date.compare(day, ending) == :gt && Date.compare(day, start) == :lt

  defp day_disabled?(_day, nil, nil), do: false
  defp day_disabled?(day, min, nil), do: Date.compare(day, min) == :lt
  defp day_disabled?(day, nil, max), do: Date.compare(day, max) == :gt

  defp day_disabled?(day, min, max),
    do: Date.compare(day, min) == :lt || Date.compare(day, max) == :gt

  defp format_date(nil), do: ""
  defp format_date(date), do: Date.to_iso8601(date)

  defp display_label("single", nil, _, _, placeholder), do: placeholder

  defp display_label("single", date, _, _, _),
    do: Calendar.strftime(date, "%B %d, %Y")

  defp display_label("range", _, nil, nil, placeholder), do: placeholder

  defp display_label("range", _, start, nil, _),
    do: "#{Calendar.strftime(start, "%b %d")} → ..."

  defp display_label("range", _, nil, ending, _),
    do: "... → #{Calendar.strftime(ending, "%b %d")}"

  defp display_label("range", _, start, ending, _),
    do: "#{Calendar.strftime(start, "%b %d")} → #{Calendar.strftime(ending, "%b %d, %Y")}"

  defp has_value?("single", selected, _), do: !is_nil(selected)
  defp has_value?("range", _, range_start), do: !is_nil(range_start)
  defp has_value?(_, _, _), do: false

  # ── Form field integration ────────────────────────────────────────────

  defp prepare_assigns(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    value = field.value

    parsed =
      case value do
        %Date{} = d ->
          d

        s when is_binary(s) and s != "" ->
          case Date.from_iso8601(s) do
            {:ok, d} -> d
            _ -> nil
          end

        _ ->
          nil
      end

    assigns
    |> assign(:name, field.name)
    |> assign(:selected, parsed)
    |> assign(:error, field.errors |> List.first() |> format_error())
    |> assign(:id, assigns[:id] || field.id)
  end

  defp prepare_assigns(assigns), do: assign_new(assigns, :error, fn -> nil end)

  defp format_error(nil), do: nil
  defp format_error({msg, _opts}), do: msg
  defp format_error(msg), do: msg
end
