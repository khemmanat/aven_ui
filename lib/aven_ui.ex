defmodule AvenUI do
  @moduledoc """
  AvenUI — 21 accessible Phoenix LiveView components.

  Free forever. MIT licensed. You own the code.

  ## Why AvenUI?

  `mix aven_ui.add` copies component source files directly into your
  project. After that, AvenUI is not a runtime dependency — your app
  works even if this library stopped being maintained tomorrow.

  ## Quick install

      # mix.exs
      {:aven_ui, "~> 0.1", github: "khemmanat/aven_ui"}

      # Terminal
      mix deps.get
      mix aven_ui.add --all

      # lib/my_app_web.ex
      use AvenUI, :components

      # assets/css/app.css
      @import "./avenui.css";

      # assets/js/app.js
      import { AvenUIHooks } from "./hooks/aven_ui"

  ## Components (21 total)

  | Component | Functions |
  |-----------|-----------|
  | `AvenUI.Components.Accordion` | `accordion/1` |
  | `AvenUI.Components.Alert` | `alert/1` |
  | `AvenUI.Components.Avatar` | `avatar/1`, `avatar_group/1` |
  | `AvenUI.Components.Badge` | `badge/1`, `badge_dot/1` |
  | `AvenUI.Components.Button` | `button/1`, `button_icon/1` |
  | `AvenUI.Components.Card` | `card/1`, `card_title/1`, `card_description/1` |
  | `AvenUI.Components.CodeBlock` | `code_block/1` |
  | `AvenUI.Components.Dropdown` | `dropdown/1`, `dropdown_item/1`, `dropdown_separator/1`, `dropdown_label/1`, `dropdown_check/1`, `dropdown_chevron/1` |
  | `AvenUI.Components.EmptyState` | `empty_state/1` |
  | `AvenUI.Components.Input` | `input/1`, `select/1` |
  | `AvenUI.Components.Kbd` | `kbd/1` |
  | `AvenUI.Components.Modal` | `modal/1` |
  | `AvenUI.Components.Progress` | `progress/1` |
  | `AvenUI.Components.Separator` | `separator/1` |
  | `AvenUI.Components.Skeleton` | `skeleton/1` |
  | `AvenUI.Components.Spinner` | `spinner/1` |
  | `AvenUI.Components.Stat` | `stat/1` |
  | `AvenUI.Components.Table` | `table/1`, `pagination/1` |
  | `AvenUI.Components.Tabs` | `tabs/1` |
  | `AvenUI.Components.Toast` | `toast/1`, `flash_group/1`, `flash_banner/1` |
  | `AvenUI.Components.Toggle` | `toggle/1` |

  ## Accessibility

  All components include ARIA attributes, keyboard navigation, and
  focus management:
  - Modal: focus trap on open, restores focus on close, Escape key
  - Dropdown: Arrow keys, Home/End, Tab, Escape
  - Tabs: keyboard navigation, `aria-selected`, `aria-controls`
  - Alert/Toast: `role="alert"`, `aria-live="polite"`
  - Table: `role="table"`, sortable columns with `aria-sort`
  - Toggle: accessible checkbox with visible focus ring

  ## JS Hooks

  8 hooks in `AvenUIHooks`:
  `Dropdown`, `Modal`, `Tooltip`, `Flash`,
  `AutoResize`, `CopyToClipboard`, `InfiniteScroll`, `ScrollTop`
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
