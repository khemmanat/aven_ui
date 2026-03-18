defmodule AvenUI.Helpers do
  @moduledoc "Shared utilities for AvenUI components."

  def classes(list) when is_list(list) do
    list
    |> List.flatten()
    |> Enum.reject(&(is_nil(&1) or &1 == false or &1 == ""))
    |> Enum.join(" ")
  end

  def classes(str) when is_binary(str), do: str
  def classes(nil), do: ""

  def focus_ring, do: "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-avn-purple focus-visible:ring-offset-2"
  def transition,  do: "transition-all duration-150 ease-in-out"
end
