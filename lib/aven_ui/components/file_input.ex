defmodule AvenUI.Components.FileInput do
  @moduledoc """
  File upload component with drag-and-drop support and progress tracking.

  ## Features

  - Drag and drop support
  - Multiple file uploads
  - File type validation
  - Size limits
  - Progress tracking
  - Preview support
  - Upload/remove functionality

  ## Examples

      <%!-- Basic file input --%>
      <.file_input id="avatar" label="Avatar" accept="image/*" />

      <%!-- Multiple files --%>
      <.file_input
        id="documents"
        label="Documents"
        multiple
        accept=".pdf,.doc,.docx"
        max_files={5}
      />

      <%!-- With upload handler --%>
      <.file_input
        id="photos"
        label="Photos"
        multiple
        accept="image/*"
        upload="upload_photo"
        on_complete="upload_complete"
      />

  ## LiveView setup

      def handle_event("upload_photo", %{"file" => file}, socket) do
        # Process upload
        {:noreply, socket}
      end

      def handle_event("upload_complete", %{"file_id" => file_id}, socket) do
        # Handle completion
        {:noreply, socket}
      end
  """

  use Phoenix.Component
  import AvenUI.Helpers

  @doc """
  File input component with drag-and-drop support.
  """
  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :label, :string, default: nil
  attr :accept, :string, default: nil, doc: "File types to accept (e.g., 'image/*', '.pdf')"
  attr :multiple, :boolean, default: false, doc: "Allow multiple file selection"
  attr :max_files, :integer, default: 1, doc: "Maximum number of files"
  attr :max_size, :integer, default: 10_000_000, doc: "Maximum file size in bytes (default: 10MB)"
  attr :disabled, :boolean, default: false
  attr :upload, :string, default: nil, doc: "Phoenix LiveView upload event name"
  attr :on_complete, :string, default: nil, doc: "Event name when upload completes"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :preview, doc: "Custom preview template for uploaded files"

  def file_input(assigns) do
    ~H"""
    <div class={classes(["w-full", @class])}>
      <%!-- Label --%>
      <label :if={@label} for={"#{@id}-input"} class="block text-sm font-medium text-avn-foreground mb-1.5">
        <%= @label %>
      </label>

      <div
        id={@id}
        phx-hook="FileInput"
        data-upload={@upload}
        data-on-complete={@on_complete}
        data-accept={@accept}
        data-multiple={@multiple}
        data-max-files={@max_files}
        data-max-size={@max_size}
        class="relative"
      >
        <%!-- Drag and drop zone --%>
        <div
          data-avn-file-dropzone
          class={classes([
            "border-2 border-dashed rounded-avn-lg p-6",
            "transition-colors duration-200",
            "flex flex-col items-center justify-center",
            "text-center cursor-pointer",
            if(@disabled,
              do: "bg-avn-muted border-avn-border opacity-50 cursor-not-allowed",
              else: "border-avn-border hover:border-avn-purple hover:bg-avn-muted/30"
            )
          ])}
        >
          <input
            id={"#{@id}-input"}
            name={@name || @id}
            type="file"
            accept={@accept}
            multiple={@multiple}
            disabled={@disabled}
            class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
            data-avn-file-input
            {@rest}
          />

          <%!-- Upload icon --%>
          <svg class="w-10 h-10 text-avn-muted-foreground mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M17 8l-5-5-5 5M12 3v12"/>
          </svg>

          <p class="text-sm font-medium text-avn-foreground mb-1">
            <%= if @multiple do %>
              Drop files here or click to upload
            <% else %>
              Drop file here or click to upload
            <% end %>
          </p>

          <p class="text-xs text-avn-muted-foreground">
            <%= build_accept_text(@accept, @max_size) %>
          </p>
        </div>

        <%!-- File list --%>
        <div data-avn-file-list class="mt-3 space-y-2">
          <%!-- Files will be rendered here by the JS hook --%>
        </div>

        <%!-- Progress bars --%>
        <div data-avn-file-progress class="mt-2 space-y-1">
          <%!-- Progress bars will be rendered here by the JS hook --%>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  File item component for displaying uploaded files.
  """
  attr :name, :string, required: true
  attr :size, :integer, required: true
  attr :type, :string, required: true
  attr :preview_url, :string, default: nil
  attr :uploading, :boolean, default: false
  attr :progress, :integer, default: 0
  attr :on_remove, :string, default: nil

  def file_item(assigns) do
    ~H"""
    <div class="flex items-center gap-3 p-3 bg-avn-muted rounded-avn border border-avn-border">
      <%!-- Preview or icon --%>
      <div class="w-10 h-10 rounded-avn bg-avn-background flex items-center justify-center shrink-0">
        <%= if @preview_url do %>
          <img src={@preview_url} alt={@name} class="w-full h-full object-cover rounded-avn" />
        <% else %>
          <svg class="w-5 h-5 text-avn-muted-foreground" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
          </svg>
        <% end %>
      </div>

      <%!-- File info --%>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium text-avn-foreground truncate">
          <%= @name %>
        </p>
        <p class="text-xs text-avn-muted-foreground">
          <%= format_file_size(@size) %>
        </p>
      </div>

      <%!-- Progress or remove button --%>
      <%= if @uploading do %>
        <div class="flex items-center gap-2">
          <div class="w-24 h-1.5 bg-avn-background rounded-full overflow-hidden">
            <div
              class="h-full bg-avn-purple transition-all duration-300"
              style={"width: #{@progress}%"}
            />
          </div>
          <span class="text-xs text-avn-muted-foreground"><%= @progress %>%</span>
        </div>
      <% else %>
        <%= if @on_remove do %>
          <button
            phx-click={@on_remove}
            class="p-1.5 rounded-avn hover:bg-avn-background text-avn-muted-foreground hover:text-avn-foreground transition-colors"
            aria-label="Remove file"
          >
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        <% end %>
      <% end %>
    </div>
    """
  end

  # Private helper functions

  defp build_accept_text(nil, max_size), do: "Any file up to #{format_file_size(max_size)}"
  defp build_accept_text(accept, max_size) do
    types = if String.contains?(accept, "/"), do: "files", else: accept
    "#{types} up to #{format_file_size(max_size)}"
  end

  defp format_file_size(bytes) when bytes < 1_000, do: "#{bytes} B"
  defp format_file_size(bytes) when bytes < 1_000_000, do: "#{div(bytes, 1_000)} KB"
  defp format_file_size(bytes) when bytes < 1_000_000_000, do: "#{Float.round(bytes / 1_000_000, 1)} MB"
  defp format_file_size(bytes), do: "#{Float.round(bytes / 1_000_000_000, 1)} GB"
end