defmodule NextGearMotorsWeb.VehicleLive.ImagesComponent do
  use NextGearMotorsWeb, :live_component

  alias NextGearMotorsWeb.VehicleLive.FormComponent

  import NextGearMotorsWeb.VehicleHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form id="upload-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <h2 class="block text-sm font-semibold leading-6 text-zinc-200">Images</h2>
        <span class="w-full flex flex-row justify-between items-center px-4 pt-3">
          <label for={@uploads.covers.ref} phx-drop-target={@uploads.covers.ref}>
            Drop a file or <.live_file_input upload={@uploads.covers} />
          </label>
          <.button type="submit" preset={:semi_transparent}>Upload</.button>
        </span>
      </form>

      <section id="upload-entries">
        <article
          :for={entry <- @uploads.covers.entries}
          :if={entry.done?}
          class="p-4 bg-zinc-800/50 rounded-3xl border border-zinc-600 flex flex-col items-center shadow-xl my-8"
        >
          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            aria-label="cancel"
            class="w-full text-right text-lg hover:text-red-400"
            phx-target={@myself}
          >
            &times;
          </button>
          <figure class="w-full flex flex-col items-center px-2">
            <.live_img_preview entry={entry} class="rounded-xl m-2 border border-zinc-500 shadow" />
            <figcaption
              title={entry.client_name}
              class="max-sm:text-sm flex flex-col sm:flex-row justify-between items-center px-8 py-2 gap-3"
            >
              <p title={entry.client_name}>{shorten_text(entry.client_name, 13)}</p>
              <progress
                title={"File Upload - #{entry.progress}%"}
                value={entry.progress}
                max="100"
                class="w-full rounded-lg"
              >
                {entry.progress}%
              </progress>
            </figcaption>
          </figure>
          <.error :for={err <- upload_errors(@uploads.covers, entry)}>{error_to_string(err)}</.error>
        </article>

        <.error :for={err <- upload_errors(@uploads.covers)}>{error_to_string(err)}</.error>
      </section>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(:covers,
       accept: ~w(.png .jpg .jpeg .avif),
       max_entries: 10
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    covers =
      consume_uploaded_entries(socket, :covers, fn %{path: path}, entry ->
        {:postpone,
         %Plug.Upload{
           content_type: entry.client_type,
           filename: entry.client_name,
           path: path
         }}
      end)

    send_update(socket.assigns.parent, covers: covers)

    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :covers, ref)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:external_client_failure), do: "Something went terribly wrong"
  defp error_to_string({:writer_failiure, reason}), do: "Failed writing image - #{reason}"
end
