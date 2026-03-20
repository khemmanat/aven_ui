defmodule AvenUI.Components.CodeBlock do
  @moduledoc """
  Code block with language label and optional copy button.
  Requires the `CopyToClipboard` JS hook for the copy feature.

  ## Examples

      <.code_block lang="elixir" copyable>
        def hello, do: "world"
      </.code_block>

      <.code_block lang="heex">
        &lt;.button variant="primary"&gt;Deploy&lt;/.button&gt;
      </.code_block>
  """

  use Phoenix.Component
  import AvenUI.Helpers

  attr :lang,     :string,  default: nil
  attr :copyable, :boolean, default: false
  attr :id,       :string,  default: nil
  attr :class,    :string,  default: nil
  slot :inner_block, required: true

  @doc """
  Renders a code block with optional language label and copy button.
  """
  def code_block(assigns) do
    id = assigns.id || "code-#{System.unique_integer([:positive])}"
    assigns = assign(assigns, :id, id)

    ~H"""
    <div class={classes(["relative rounded-avn-lg border border-avn-border overflow-hidden", @class])}>
      <%= if @lang || @copyable do %>
        <div class="flex items-center justify-between px-4 py-2 bg-avn-muted border-b border-avn-border">
          <span :if={@lang} class="text-xs font-mono font-medium text-avn-muted-foreground uppercase tracking-wide">
            <%= @lang %>
          </span>
          <span :if={!@lang} />

          <button
            :if={@copyable}
            type="button"
            id={"copy-btn-#{@id}"}
            phx-hook="CopyToClipboard"
            data-copy-text={render_slot(@inner_block)}
            class="flex items-center gap-1.5 text-xs text-avn-muted-foreground hover:text-avn-foreground transition-colors"
            aria-label="Copy code"
          >
            <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
              <path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/>
            </svg>
            Copy
          </button>
        </div>
      <% end %>

      <pre class="overflow-x-auto p-4 text-sm font-mono leading-relaxed text-avn-foreground bg-avn-card"><code id={@id}><%= render_slot(@inner_block) %></code></pre>
    </div>
    """
  end
end
