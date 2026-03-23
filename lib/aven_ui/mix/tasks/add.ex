defmodule Mix.Tasks.AvenUi.Add do
  @shortdoc "Add AvenUI components to your Phoenix project"

  @moduledoc """
  Copies AvenUI component source files into your project so you own them.

  ## Usage

      mix aven_ui.add button badge alert
      mix aven_ui.add --all
      mix aven_ui.add button --path lib/my_app_web/components/ui
      mix aven_ui.add --all --dry-run
  """

  use Mix.Task

  @components ~w(
    accordion alert avatar badge button card code_block combobox
    dropdown empty_state input kbd modal progress
    separator skeleton spinner stat table tabs toast toggle
  )

  @component_files %{
    "accordion" => "lib/aven_ui/components/accordion.ex",
    "alert" => "lib/aven_ui/components/alert.ex",
    "combobox" => "lib/aven_ui/components/combobox.ex",
    "avatar" => "lib/aven_ui/components/avatar.ex",
    "badge" => "lib/aven_ui/components/badge.ex",
    "button" => "lib/aven_ui/components/button.ex",
    "card" => "lib/aven_ui/components/card.ex",
    "code_block" => "lib/aven_ui/components/code_block.ex",
    "dropdown" => "lib/aven_ui/components/dropdown.ex",
    "empty_state" => "lib/aven_ui/components/empty_state.ex",
    "input" => "lib/aven_ui/components/input.ex",
    "kbd" => "lib/aven_ui/components/kbd.ex",
    "modal" => "lib/aven_ui/components/modal.ex",
    "progress" => "lib/aven_ui/components/progress.ex",
    "separator" => "lib/aven_ui/components/separator.ex",
    "skeleton" => "lib/aven_ui/components/skeleton.ex",
    "spinner" => "lib/aven_ui/components/spinner.ex",
    "stat" => "lib/aven_ui/components/stat.ex",
    "table" => "lib/aven_ui/components/table.ex",
    "tabs" => "lib/aven_ui/components/tabs.ex",
    "toast" => "lib/aven_ui/components/toast.ex",
    "toggle" => "lib/aven_ui/components/toggle.ex"
  }

  @impl Mix.Task
  def run(args) do
    {opts, components, _} =
      OptionParser.parse(args,
        strict: [all: :boolean, path: :string, dry_run: :boolean]
      )

    components = if opts[:all], do: @components, else: components

    if components == [] do
      Mix.shell().error(
        "No components specified.\n\nUsage:\n  mix aven_ui.add button badge\n  mix aven_ui.add --all"
      )

      exit({:shutdown, 1})
    end

    invalid = Enum.reject(components, &Map.has_key?(@component_files, &1))

    unless invalid == [] do
      Mix.shell().error("Unknown components: #{Enum.join(invalid, ", ")}")
      Mix.shell().info("Available: #{Enum.join(@components, ", ")}")
      exit({:shutdown, 1})
    end

    dry_run = opts[:dry_run] || false
    dest_dir = opts[:path] || default_dest_dir()

    Mix.shell().info([:cyan, "AvenUI", :reset, " — adding #{length(components)} component(s)\n"])

    Enum.each(components, fn name ->
      copy_file(
        dep_path(Map.fetch!(@component_files, name)),
        Path.join(dest_dir, "#{name}.ex"),
        dry_run,
        :green,
        &rewrite_namespace/1
      )
    end)

    copy_file(
      dep_path("lib/aven_ui/helpers.ex"),
      Path.join(dest_dir, "helpers.ex"),
      dry_run,
      :green,
      &rewrite_namespace/1
    )

    copy_file(
      dep_path("assets/css/avenui.css"),
      Path.join(File.cwd!(), "assets/css/avenui.css"),
      dry_run,
      :blue,
      & &1
    )

    copy_file(
      dep_path("assets/js/hooks/index.js"),
      Path.join(File.cwd!(), "assets/js/hooks/aven_ui.js"),
      dry_run,
      :blue,
      & &1
    )

    print_next_steps(components, dest_dir, dry_run)
  end

  defp copy_file(source, dest, dry_run, color, transform) do
    if File.exists?(dest) do
      Mix.shell().info([:yellow, "  skip   ", :reset, dest])
    else
      Mix.shell().info([
        color,
        if(dry_run, do: "  dry-run", else: "  create"),
        :reset,
        "  #{dest}"
      ])

      unless dry_run do
        File.mkdir_p!(Path.dirname(dest))
        File.write!(dest, source |> File.read!() |> transform.())
      end
    end
  end

  defp rewrite_namespace(content) do
    web = Mix.Project.config()[:app] |> to_string() |> Macro.camelize()

    content
    |> String.replace("AvenUI.Components", "#{web}Web.UI")
    |> String.replace("AvenUI.Helpers", "#{web}Web.UI.Helpers")
  end

  defp default_dest_dir do
    app = Mix.Project.config()[:app]
    Path.join(["lib", "#{app}_web", "components", "ui"])
  end

  defp dep_path(relative) do
    # Mix.Project.deps_path() returns the deps/ directory of the consuming project.
    # From there we navigate into deps/aven_ui/ to find the source files.
    # This works whether aven_ui is a local path dep or fetched from GitHub/Hex.
    deps_dir = Mix.Project.deps_path()
    path = Path.join([deps_dir, "aven_ui", relative]) |> Path.expand()

    if File.exists?(path) do
      path
    else
      # Fallback for when running tasks inside the aven_ui repo itself (development)
      fallback = Path.join([__DIR__, "../../../../..", relative]) |> Path.expand()

      if File.exists?(fallback) do
        fallback
      else
        Mix.raise(
          "AvenUI: could not find source file at #{path}\n" <>
            "Make sure you ran `mix deps.get` first."
        )
      end
    end
  end

  defp print_next_steps(_, _, true), do: Mix.shell().info("\n(dry run — no files written)")

  defp print_next_steps(components, dest_dir, false) do
    app = Mix.Project.config()[:app]
    web = app |> to_string() |> Macro.camelize()

    imports =
      Enum.map_join(components, "\n      ", fn c ->
        "import #{web}Web.UI.#{Macro.camelize(c)}"
      end)

    Mix.shell().info("""

    #{IO.ANSI.green()}✓ Done!#{IO.ANSI.reset()} Copied to #{dest_dir}

    Next steps:

    1. lib/#{app}_web.ex — html_helpers/0:
         #{imports}

    2. assets/css/app.css — replace existing imports with:
         @import "tailwindcss";
         @import "../../deps/aven_ui/assets/css/avenui.css";
         @source "../../deps/aven_ui/lib/**/*.ex";

       No tailwind.config.js needed — Tailwind v4 is CSS-first.

    3. assets/js/app.js:
         import { AvenUIHooks } from "./hooks/aven_ui"
         let liveSocket = new LiveSocket("/live", Socket, {
           hooks: { ...AvenUIHooks, ...Hooks }
         })
    """)
  end
end
