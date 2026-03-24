defmodule Mix.Tasks.AvenUi.New do
  @shortdoc "Create a new Phoenix 1.8 project with AvenUI pre-installed"

  @moduledoc """
  Scaffolds a full Phoenix 1.8 project with AvenUI pre-wired.

  ## Usage

      mix aven_ui.new my_app
      mix aven_ui.new my_app --module MyApp
      mix aven_ui.new my_app --path ~/projects

  ## What it generates

  - Full Phoenix 1.8 app via `mix phx.new`
  - AvenUI added to `mix.exs` deps
  - All 23 components installed via `mix aven_ui.add --all`
  - `app.css` configured for Tailwind v4 + AvenUI tokens
  - `app.js` wired with `AvenUIHooks`
  - `web.ex` updated with all component imports
  - Starter layout: navbar + sidebar + dashboard home page
  - Dark mode toggle wired and working

  ## Options

      --module      App module name (default: PascalCase of app name)
      --path        Where to create the project (default: current dir)
      --no-ecto     Skip Ecto/database setup
      --no-mailer   Skip Swoosh mailer setup
  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {opts, argv, _} = OptionParser.parse(args,
      strict: [module: :string, path: :string, no_ecto: :boolean, no_mailer: :boolean]
    )

    app_name = List.first(argv) || Mix.raise("""
    Usage: mix aven_ui.new APP_NAME

    Example:
      mix aven_ui.new my_app
      mix aven_ui.new my_saas --no-ecto
    """)

    unless valid_app_name?(app_name) do
      Mix.raise("Invalid app name: #{app_name}. Use snake_case (e.g. my_app)")
    end

    module    = opts[:module]   || module_name(app_name)
    base_path = opts[:path]     || File.cwd!()
    app_path  = Path.join(base_path, app_name)

    Mix.shell().info("""

    \e[35m  AvenUI\e[0m — Creating new Phoenix 1.8 project

      App:    #{app_name}
      Module: #{module}
      Path:   #{app_path}
    """)

    # ── Step 1: Run mix phx.new ──────────────────────────────────────
    step("Running mix phx.new…")

    phx_flags = build_phx_flags(opts, app_name, module, base_path)

    case Mix.shell().cmd("mix phx.new #{phx_flags}") do
      0 -> Mix.shell().info("  ✓ Phoenix project created")
      _ -> Mix.raise("mix phx.new failed. Is Phoenix installed? Run: mix archive.install hex phx_new")
    end

    # ── Step 2: Add aven_ui to mix.exs ──────────────────────────────
    step("Adding aven_ui dependency…")
    mix_exs_path = Path.join(app_path, "mix.exs")
    inject_dep(mix_exs_path, app_name)

    # ── Step 3: Install deps ─────────────────────────────────────────
    step("Fetching dependencies…")
    cmd_in(app_path, "mix deps.get")

    # ── Step 4: Install components ───────────────────────────────────
    step("Installing AvenUI components…")
    cmd_in(app_path, "mix aven_ui.add --all")

    # ── Step 5: Wire app.css ─────────────────────────────────────────
    step("Configuring Tailwind v4 + AvenUI tokens…")
    write_app_css(app_path)

    # ── Step 6: Wire app.js ──────────────────────────────────────────
    step("Wiring AvenUIHooks…")
    patch_app_js(app_path, app_name)

    # ── Step 7: Update web.ex ────────────────────────────────────────
    step("Importing components in web.ex…")
    patch_web_ex(app_path, app_name, module)

    # ── Step 8: Generate starter layout ─────────────────────────────
    step("Generating starter layout (navbar + sidebar + dashboard)…")
    write_root_layout(app_path, app_name, module)
    write_app_layout(app_path, app_name, module)
    write_dashboard_live(app_path, app_name, module)
    patch_router(app_path, app_name, module)

    # ── Done ─────────────────────────────────────────────────────────
    Mix.shell().info("""

    \e[32m  ✓ Done!\e[0m AvenUI project ready.

      \e[90mcd #{app_name}\e[0m
      \e[90mmix phx.server\e[0m

      Then open: http://localhost:4000

    \e[35m  23 components\e[0m available. Full docs at https://aven.khemkim.com
    """)
  end

  # ── Helpers ───────────────────────────────────────────────────────────

  defp step(msg), do: Mix.shell().info("  \e[35m→\e[0m #{msg}")

  defp cmd_in(path, cmd) do
    case Mix.shell().cmd("cd #{path} && #{cmd}") do
      0 -> :ok
      _ -> Mix.raise("Command failed: #{cmd}")
    end
  end

  defp build_phx_flags(opts, app_name, module, base_path) do
    flags = ["#{Path.join(base_path, app_name)}"]
    flags = if opts[:module],    do: flags ++ ["--module #{module}"],    else: flags
    flags = if opts[:no_ecto],   do: flags ++ ["--no-ecto"],             else: flags
    flags = if opts[:no_mailer], do: flags ++ ["--no-mailer"],           else: flags
    Enum.join(flags, " ")
  end

  defp inject_dep(mix_exs_path, _app_name) do
    content = File.read!(mix_exs_path)

    unless String.contains?(content, "aven_ui") do
      # Insert after {:phoenix, ...} line
      updated = String.replace(
        content,
        ~r/(\{:phoenix,\s*"[^"]+"\})/,
        "\\1,\n      {:aven_ui, \"~> 0.2\", hex: :aven_ui}"
      )
      File.write!(mix_exs_path, updated)
    end
  end

  defp write_app_css(app_path) do
    css_path = Path.join([app_path, "assets", "css", "app.css"])
    existing = File.read!(css_path)

    # Prepend AvenUI imports if not already there
    unless String.contains?(existing, "aven_ui") do
      aven_imports = """
      @import "../../deps/aven_ui/assets/css/avenui.css";
      @source "../../deps/aven_ui/lib";

      """
      File.write!(css_path, aven_imports <> existing)
    end
  end

  defp patch_app_js(app_path, _app_name) do
    js_path = Path.join([app_path, "assets", "js", "app.js"])
    content = File.read!(js_path)

    unless String.contains?(content, "AvenUIHooks") do
      # Add import after existing imports block
      updated = String.replace(
        content,
        ~r/(import \{.*?LiveSocket.*?\}.*?\n)/,
        "\\1import { AvenUIHooks } from \"../../deps/aven_ui/assets/js/hooks/index.js\"\n"
      )

      # Wire hooks into liveSocket
      updated = String.replace(
        updated,
        "let liveSocket = new LiveSocket(\"/live\", Socket, {",
        "let liveSocket = new LiveSocket(\"/live\", Socket, {\n  hooks: { ...AvenUIHooks },"
      )

      File.write!(js_path, updated)
    end
  end

  defp patch_web_ex(app_path, app_name, _module) do
    web_ex_path = Path.join([app_path, "lib", "#{app_name}_web.ex"])
    content = File.read!(web_ex_path)

    unless String.contains?(content, "AvenUI") do
      web_module = module_name(app_name) <> "Web"

      aven_imports = ~w(
        Accordion Alert Avatar Badge Button Card CodeBlock Combobox
        DatePicker Dropdown EmptyState Input Kbd Modal Progress
        Separator Skeleton Spinner Stat Table Tabs Toast Toggle
      )
      |> Enum.map(&"      import #{web_module}.UI.#{&1}")
      |> Enum.join("\n")

      # Inject before CoreComponents import
      updated = String.replace(
        content,
        "      import #{web_module}.CoreComponents",
        "#{aven_imports}\n      import #{web_module}.CoreComponents"
      )

      File.write!(web_ex_path, updated)
    end
  end

  defp write_root_layout(app_path, app_name, module) do
    _web_module = module <> "Web"
    path = Path.join([app_path, "lib", "#{app_name}_web", "components", "layouts", "root.html.heex"])

    File.write!(path, """
    <!DOCTYPE html>
    <html lang="en" class={if assigns[:dark_mode], do: "dark", else: ""}>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={get_csrf_token()} />
        <.live_title suffix=" · #{module}">
          <%= assigns[:page_title] || "#{module}" %>
        </.live_title>
        <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}>
        </script>
      </head>
      <body class="bg-avn-background text-avn-foreground antialiased">
        <%= @inner_content %>
      </body>
    </html>
    """)
  end

  defp write_app_layout(app_path, app_name, module) do
    _web_module = module <> "Web"
    path = Path.join([app_path, "lib", "#{app_name}_web", "components", "layouts", "app.html.heex"])

    File.write!(path, """
    <div class="flex h-screen overflow-hidden">

      <%!-- Sidebar --%>
      <aside class="hidden md:flex flex-col w-56 shrink-0 border-r border-avn-border bg-avn-card">

        <%!-- Logo --%>
        <div class="flex items-center gap-2.5 px-4 h-14 border-b border-avn-border">
          <div class="w-7 h-7 rounded-lg bg-avn-purple flex items-center justify-center text-white text-xs font-bold">
            A
          </div>
          <span class="font-semibold text-sm text-avn-foreground">#{module}</span>
        </div>

        <%!-- Nav links --%>
        <nav class="flex-1 px-2 py-3 space-y-0.5 overflow-y-auto">
          <a href={~p"/"} class="flex items-center gap-2.5 px-3 py-2 rounded-avn text-sm text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted transition-colors">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>
            Dashboard
          </a>
          <a href="#" class="flex items-center gap-2.5 px-3 py-2 rounded-avn text-sm text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted transition-colors">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            Users
          </a>
          <a href="#" class="flex items-center gap-2.5 px-3 py-2 rounded-avn text-sm text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted transition-colors">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>
            Projects
          </a>
          <a href="#" class="flex items-center gap-2.5 px-3 py-2 rounded-avn text-sm text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted transition-colors">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 20V10"/><path d="M12 20V4"/><path d="M6 20v-6"/></svg>
            Analytics
          </a>
          <a href="#" class="flex items-center gap-2.5 px-3 py-2 rounded-avn text-sm text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted transition-colors">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14M4.93 4.93a10 10 0 0 0 0 14.14"/></svg>
            Settings
          </a>
        </nav>

        <%!-- Bottom user area --%>
        <div class="p-3 border-t border-avn-border">
          <div class="flex items-center gap-2.5 px-2 py-1.5 rounded-avn hover:bg-avn-muted transition-colors cursor-pointer">
            <.avatar initials="U" size="sm" />
            <div class="flex-1 min-w-0">
              <p class="text-xs font-medium text-avn-foreground truncate">User</p>
              <p class="text-[10px] text-avn-muted-foreground truncate">user@example.com</p>
            </div>
          </div>
        </div>
      </aside>

      <%!-- Main area --%>
      <div class="flex flex-col flex-1 overflow-hidden">

        <%!-- Top navbar --%>
        <header class="flex items-center justify-between h-14 px-6 border-b border-avn-border bg-avn-card shrink-0">
          <h1 class="text-sm font-semibold text-avn-foreground">
            <%= assigns[:page_title] || "Dashboard" %>
          </h1>
          <div class="flex items-center gap-2">
            <.flash_group flash={@flash} />
            <%!-- Dark mode toggle --%>
            <button
              phx-click="toggle_dark"
              class="w-8 h-8 flex items-center justify-center rounded-avn border border-avn-border
                     text-avn-muted-foreground hover:text-avn-foreground hover:bg-avn-muted transition-colors"
              aria-label="Toggle dark mode"
            >
              <svg class="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
              </svg>
            </button>
          </div>
        </header>

        <%!-- Page content --%>
        <main class="flex-1 overflow-y-auto p-6">
          <%= @inner_content %>
        </main>
      </div>
    </div>
    """)
  end

  defp write_dashboard_live(app_path, app_name, module) do
    web_module = module <> "Web"
    dir  = Path.join([app_path, "lib", "#{app_name}_web", "live"])
    File.mkdir_p!(dir)
    path = Path.join(dir, "dashboard_live.ex")

    File.write!(path, """
    defmodule #{web_module}.DashboardLive do
      use #{web_module}, :live_view

      @impl true
      def mount(_params, _session, socket) do
        {:ok,
         socket
         |> assign(:page_title, "Dashboard")
         |> assign(:dark_mode, false)
         |> assign(:selected_date, nil)
         |> assign(:range_start, nil)
         |> assign(:range_end, nil)
         |> assign(:dp_month, Date.utc_today())}
      end

      @impl true
      def handle_event("toggle_dark", _, socket) do
        {:noreply, update(socket, :dark_mode, &(!&1))}
      end

      def handle_event("date_picked", %{"date" => date_str, "mode" => "single"}, socket) do
        date = Date.from_iso8601!(date_str)
        {:noreply, assign(socket, :selected_date, date)}
      end

      def handle_event("date_picked", %{"date" => date_str, "mode" => "range"}, socket) do
        date = Date.from_iso8601!(date_str)
        cond do
          is_nil(socket.assigns.range_start) ->
            {:noreply, assign(socket, range_start: date, range_end: nil)}
          is_nil(socket.assigns.range_end) ->
            start = socket.assigns.range_start
            {s, e} = if Date.compare(date, start) == :lt, do: {date, start}, else: {start, date}
            {:noreply, assign(socket, range_start: s, range_end: e)}
          true ->
            {:noreply, assign(socket, range_start: date, range_end: nil)}
        end
      end

      def handle_event("dp_prev_month_" <> _id, _, socket) do
        prev = socket.assigns.dp_month |> Date.add(-1) |> Date.beginning_of_month()
        {:noreply, assign(socket, :dp_month, prev)}
      end

      def handle_event("dp_next_month_" <> _id, _, socket) do
        next = socket.assigns.dp_month |> Date.add(32) |> Date.beginning_of_month()
        {:noreply, assign(socket, :dp_month, next)}
      end

      def handle_event("dp_clear_" <> _id, _, socket) do
        {:noreply, assign(socket, selected_date: nil, range_start: nil, range_end: nil)}
      end

      def handle_event(_, _, socket), do: {:noreply, socket}

      @impl true
      def render(assigns) do
        ~H\"""
        <div class="space-y-8 max-w-5xl">

          <%!-- Stat cards --%>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <.stat label="Total users"   value="2,481"  change="+12%"  trend="up" />
            <.stat label="Revenue"       value="48,200" prefix="$"     change="+8.2%" trend="up" />
            <.stat label="Active now"    value="142"                   change="-3"    trend="down" />
            <.stat label="Uptime"        value="99.97"  suffix="%"  />
          </div>

          <%!-- Two column: alerts + date pickers --%>
          <div class="grid md:grid-cols-2 gap-6">

            <%!-- Alerts showcase --%>
            <.card>
              <:header><.card_title>System Status</.card_title></:header>
              <:body>
                <div class="space-y-2">
                  <.alert variant="success" title="All systems operational">
                    No incidents in the last 30 days.
                  </.alert>
                  <.alert variant="warning" title="Scheduled maintenance">
                    Database migration on Sunday 2:00 AM UTC.
                  </.alert>
                  <.alert variant="info" title="AvenUI v0.2.2">
                    Date picker and project generator now available.
                  </.alert>
                </div>
              </:body>
            </.card>

            <%!-- Date pickers --%>
            <.card>
              <:header><.card_title>Date Picker</.card_title></:header>
              <:body>
                <div class="space-y-4">
                  <.date_picker
                    id="single-demo"
                    name="demo_date"
                    label="Single date"
                    selected={@selected_date}
                    view_month={@dp_month}
                    on_change="date_picked"
                  />
                  <.date_picker
                    id="range-demo"
                    name="range"
                    label="Date range"
                    mode="range"
                    range_start={@range_start}
                    range_end={@range_end}
                    view_month={@dp_month}
                    on_change="date_picked"
                  />
                </div>
              </:body>
            </.card>
          </div>

          <%!-- Component badges --%>
          <.card>
            <:header><.card_title>23 Components Available</.card_title></:header>
            <:body>
              <div class="flex flex-wrap gap-2">
                <%= for name <- ~w(Accordion Alert Avatar Badge Button Card CodeBlock Combobox DatePicker
                                   Dropdown EmptyState Input Kbd Modal Progress Separator Skeleton
                                   Spinner Stat Table Tabs Toast Toggle) do %>
                  <.badge variant="info"><%= name %></.badge>
                <% end %>
              </div>
            </:body>
          </.card>

        </div>
        \"""
      end
    end
    """)
  end

  defp patch_router(app_path, app_name, module) do
    web_module = module <> "Web"
    router_path = Path.join([app_path, "lib", "#{app_name}_web", "router.ex"])
    content = File.read!(router_path)

    unless String.contains?(content, "DashboardLive") do
      updated = String.replace(
        content,
        ~r/(scope "\/", #{Regex.escape(web_module)} do\s*\n\s*pipe_through :browser\s*\n)/,
        "\\1\n    live \"/\", DashboardLive\n"
      )
      File.write!(router_path, updated)
    end
  end

  defp valid_app_name?(name) do
    name =~ ~r/^[a-z][a-z0-9_]*$/
  end

  defp module_name(app_name) do
    app_name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join()
  end
end
