defmodule Mix.Tasks.AvenUi.List do
  @shortdoc "List all available AvenUI components"
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    Mix.shell().info("""

    AvenUI — 21 Phoenix LiveView components

    Actions:    button, dropdown
    Display:    avatar, badge, progress, skeleton, stat
    Feedback:   alert, toast
    Overlay:    modal
    Layout:     accordion, card
    Navigation: tabs
    Forms:      input, toggle
    Data:       table
    Utilities:  code_block, empty_state, kbd, separator, spinner

    Install all:  mix aven_ui.add --all
    Install one:  mix aven_ui.add button
    """)
  end
end
