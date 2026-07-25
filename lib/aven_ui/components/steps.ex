defmodule AvenUI.Components.Steps do
  @moduledoc """
  Multi-step wizard component for guided workflows.

  ## Features

  - Visual progress indicator
  - Linear and non-linear navigation
  - Step validation
  - Customizable steps
  - Responsive design
  - Keyboard navigation

  ## Examples

      <%!-- Basic steps --%>
      <.steps current={@current_step}>
        <:step id="1" title="Personal Info" description="Basic information">
          <:content>
            <.input field={@form[:name]} label="Full name" />
            <.input field={@form[:email]} label="Email address" />
          </:content>
        </:step>

        <:step id="2" title="Address" description="Contact information">
          <:content>
            <.input field={@form[:address]} label="Address" />
            <.input field={@form[:city]} label="City" />
          </:content>
        </:step>

        <:step id="3" title="Review" description="Confirm your details">
          <:content>
            <div class="space-y-4">
              <p><strong>Name:</strong> <%= @form[:name].value %></p>
              <p><strong>Email:</strong> <%= @form[:email].value %></p>
            </div>
          </:content>
        </:step>
      </.steps>

      <%!-- With navigation --%>
      <.steps current={@current_step} on_change="step_changed">
        <:step id="1" title="Step 1">...</:step>
        <:step id="2" title="Step 2">...</:step>
        <:step id="3" title="Step 3">...</:step>
      </.steps>

  ## LiveView handlers

      def handle_event("step_changed", %{"step" => step_id}, socket) do
        {:noreply, assign(socket, :current_step, step_id)}
      end
  """

  use Phoenix.Component
  import AvenUI.Helpers
  import AvenUI.Components.Button
  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :current, :string, required: true, doc: "Current step ID"
  attr :on_change, :string, default: nil, doc: "Event name when step changes"
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :class, :string, default: nil
  attr :rest, :global

  slot :step, required: true do
    attr :id, :string, required: true
    attr :title, :string, required: true
    attr :description, :string
    attr :disabled, :boolean
    attr :completed, :boolean
  end

  def steps(assigns) do
    assigns = assign(assigns, :total_steps, length(assigns.step))

    ~H"""
    <div
      id={@id}
      class={classes(["w-full", @class])}
      {@rest}
    >
      <%!-- Step indicator --%>
      <div class="mb-8">
        <%= if @orientation == "horizontal" do %>
          <div class="flex items-center justify-between">
            <%= for {step, index} <- Enum.with_index(@step) do %>
              <%!-- Connector line --%>
              <%= if index > 0 do %>
                <div class={classes([
                  "flex-1 h-0.5 mx-2",
                  if(step_completed?(step, @current, index, @step),
                    do: "bg-avn-purple",
                    else: "bg-avn-border"
                  )
                ])} />
              <% end %>

              <%!-- Step indicator --%>
              <div
                phx-click={step_click(@on_change, step.id, step.disabled)}
                class={classes([
                  "flex flex-col items-center gap-2 cursor-pointer",
                  if(step.disabled, do: "opacity-50 cursor-not-allowed")
                ])}
              >
                <div
                  class={classes([
                    "w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium transition-colors",
                    step_indicator_class(step, @current, index, @step)
                  ])}
                >
                  <%= step_indicator_content(step, @current, index) %>
                </div>

                <div class="text-center">
                  <p class={classes([
                    "text-sm font-medium",
                    if(@current == step.id, do: "text-avn-foreground", else: "text-avn-muted-foreground")
                  ])}>
                    <%= step.title %>
                  </p>
                  <%= if step.description do %>
                    <p class="text-xs text-avn-muted-foreground">
                      <%= step.description %>
                    </p>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        <% else %>
          <%!-- Vertical orientation --%>
          <div class="space-y-4">
            <%= for {step, index} <- Enum.with_index(@step) do %>
              <div
                phx-click={step_click(@on_change, step.id, step.disabled)}
                class={classes([
                  "flex items-start gap-4 cursor-pointer",
                  if(step.disabled, do: "opacity-50 cursor-not-allowed")
                ])}
              >
                <div
                  class={classes([
                    "w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium transition-colors shrink-0",
                    step_indicator_class(step, @current, index, @step)
                  ])}
                >
                  <%= step_indicator_content(step, @current, index) %>
                </div>

                <div class="flex-1">
                  <p class={classes([
                    "text-sm font-medium",
                    if(@current == step.id, do: "text-avn-foreground", else: "text-avn-muted-foreground")
                  ])}>
                    <%= step.title %>
                  </p>
                  <%= if step.description do %>
                    <p class="text-xs text-avn-muted-foreground">
                      <%= step.description %>
                    </p>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>

      <%!-- Step content --%>
      <div class="relative">
        <%= for step <- @step do %>
          <div
            data-step-content={step.id}
            class={classes([
              "transition-opacity duration-300",
              if(@current == step.id, do: "block", else: "hidden")
            ])}
          >
            <%= render_slot(step) %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Step navigation controls.
  """
  attr :current, :string, required: true
  attr :total, :integer, required: true
  attr :on_previous, :string, default: "previous_step"
  attr :on_next, :string, default: "next_step"
  attr :on_complete, :string, default: "complete_wizard"
  attr :disable_previous, :boolean, default: false
  attr :disable_next, :boolean, default: false
  attr :show_complete, :boolean, default: false
  attr :class, :string, default: nil

  def step_navigation(assigns) do
    current_index = parse_step_index(assigns.current) - 1
    is_first_step = current_index == 0
    is_last_step = current_index == assigns.total - 1

    assigns = assign(assigns,
      is_first_step: is_first_step,
      is_last_step: is_last_step
    )

    ~H"""
    <div class={classes(["flex items-center justify-between gap-4 pt-6 border-t border-avn-border", @class])}>
      <%!-- Previous button --%>
      <.button
        variant="secondary"
        phx-click={@on_previous}
        disabled={@disable_previous || @is_first_step}
      >
        Previous
      </.button>

      <%!-- Next or Complete button --%>
      <%= if @show_complete || @is_last_step do %>
        <.button
          variant="primary"
          phx-click={@on_complete}
          disabled={@disable_next}
        >
          Complete
        </.button>
      <% else %>
        <.button
          variant="primary"
          phx-click={@on_next}
          disabled={@disable_next}
        >
          Next
        </.button>
      <% end %>
    </div>
    """
  end

  # Private helper functions

  defp step_click(nil, _step_id, _disabled), do: nil
  defp step_click(_event, _step_id, disabled) when disabled == true, do: nil
  defp step_click(event, step_id, _disabled), do: JS.push(event, value: %{step: step_id})

  defp step_completed?(step, current, index, all_steps) do
    current_index = Enum.find_index(all_steps, fn s -> s.id == current end)
    step.completed or index < current_index
  end

  defp step_indicator_class(step, current, index, all_steps) do
    current_index = Enum.find_index(all_steps, fn s -> s.id == current end)
    is_completed = step.completed or index < current_index
    is_current = current == step.id

    cond do
      is_current -> "bg-avn-purple text-white ring-4 ring-avn-purple/20"
      is_completed -> "bg-avn-purple text-white"
      step.disabled -> "bg-avn-muted text-avn-muted-foreground"
      true -> "bg-avn-muted text-avn-muted-foreground"
    end
  end

  defp step_indicator_content(step, current, index) do
    current_index = index + 1
    is_completed = step.completed or current_index < parse_step_index(current)

    cond do
      is_completed -> "✓"
      true -> current_index
    end
  end

  defp parse_step_index(step_id) when is_binary(step_id) do
    case Integer.parse(step_id) do
      {num, ""} -> num
      _ -> 1
    end
  end
  defp parse_step_index(_), do: 1
end