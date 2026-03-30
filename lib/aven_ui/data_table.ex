defmodule AvenUI.DataTable do
  @moduledoc """
  State helper for the `data_table/1` component.

  Manages filter, sort, and pagination state in a single struct
  that lives in your LiveView assigns. All filtering and sorting
  happens server-side — you control the query.

  ## Setup

      alias AvenUI.DataTable

      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> assign(:table, DataTable.new(per_page: 20))
         |> load_rows()}
      end

      # Reload rows whenever table state changes
      defp load_rows(socket) do
        %{filter: filter, sort_field: field, sort_dir: dir,
          page: page, per_page: per} = socket.assigns.table

        {rows, total} = Accounts.list_users(
          search: filter["search"],
          status: filter["status"],
          sort_field: field,
          sort_dir: dir,
          page: page,
          per_page: per
        )

        socket
        |> assign(:rows, rows)
        |> assign(:table, DataTable.put_total(socket.assigns.table, total))
      end

  ## Handle events

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
  """

  @enforce_keys []
  defstruct filter: %{},
            sort_field: nil,
            sort_dir: "asc",
            page: 1,
            per_page: 20,
            total: 0

  @type t :: %__MODULE__{
          filter: map(),
          sort_field: String.t() | nil,
          sort_dir: String.t(),
          page: pos_integer(),
          per_page: pos_integer(),
          total: non_neg_integer()
        }

  @doc "Create a new DataTable state struct."
  def new(opts \\ []) do
    struct(__MODULE__, opts)
  end

  @doc "Update filter params. Strips blank values."
  def set_filter(%__MODULE__{} = dt, params) when is_map(params) do
    clean =
      params
      |> Map.reject(fn {_, v} -> is_nil(v) || v == "" end)

    %{dt | filter: clean}
  end

  @doc "Toggle sort on a field. Flips direction if already sorted by that field."
  def toggle_sort(%__MODULE__{sort_field: field, sort_dir: dir} = dt, new_field) do
    {new_field_str, new_dir} =
      if to_string(field) == to_string(new_field) do
        {new_field, if(dir == "asc", do: "desc", else: "asc")}
      else
        {new_field, "asc"}
      end

    %{dt | sort_field: new_field_str, sort_dir: new_dir}
  end

  @doc "Set the current page."
  def set_page(%__MODULE__{} = dt, page) when is_integer(page) and page >= 1 do
    %{dt | page: page}
  end

  @doc "Reset to page 1 (call after filter changes)."
  def reset_page(%__MODULE__{} = dt), do: %{dt | page: 1}

  @doc "Set total row count (used to compute total_pages)."
  def put_total(%__MODULE__{} = dt, total) when is_integer(total) do
    %{dt | total: total}
  end

  @doc "Compute total pages from total rows and per_page."
  def total_pages(%__MODULE__{total: total, per_page: per}) do
    max(1, ceil(total / per))
  end

  @doc "Compute the SQL/Ecto offset for the current page."
  def offset(%__MODULE__{page: page, per_page: per}) do
    (page - 1) * per
  end

  @doc "True if any filter is active."
  def filtered?(%__MODULE__{filter: f}), do: map_size(f) > 0

  @doc "Returns the filter value for a given key."
  def filter_value(%__MODULE__{filter: f}, key) do
    Map.get(f, to_string(key), "")
  end
end
