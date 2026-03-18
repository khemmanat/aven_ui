defmodule AvenUI do
  @moduledoc """
  AvenUI — A free, open-source UI component library for Phoenix LiveView.

  ## Quick setup

      # mix.exs
      {:aven_ui, "~> 0.1", github: "yourname/aven_ui"}

      # Terminal
      mix aven_ui.add --all

      # lib/my_app_web.ex
      use AvenUI, :components

      # assets/css/app.css
      @import "./avenui.css";

      # assets/js/app.js
      import { AvenUIHooks } from "./hooks/aven_ui"
  """

  defmacro __using__(:components) do
    quote do
      import AvenUI.Components.Accordion
      import AvenUI.Components.Alert
      import AvenUI.Components.Avatar
      import AvenUI.Components.Badge
      import AvenUI.Components.Button
      import AvenUI.Components.Card
      import AvenUI.Components.CodeBlock
      import AvenUI.Components.Dropdown
      import AvenUI.Components.EmptyState
      import AvenUI.Components.Input
      import AvenUI.Components.Kbd
      import AvenUI.Components.Modal
      import AvenUI.Components.Progress
      import AvenUI.Components.Separator
      import AvenUI.Components.Skeleton
      import AvenUI.Components.Spinner
      import AvenUI.Components.Stat
      import AvenUI.Components.Table
      import AvenUI.Components.Tabs
      import AvenUI.Components.Toast
      import AvenUI.Components.Toggle
    end
  end

  def version, do: Mix.Project.config()[:version]
end
