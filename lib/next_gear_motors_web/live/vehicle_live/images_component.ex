defmodule NextGearMotorsWeb.VehicleLive.ImagesComponent do
  use NextGearMotorsWeb, :live_component

  alias NextGearMotorsWeb.VehicleLive.FormComponent
  alias NextGearMotors.Vehicles.Covers.Cover

  import NextGearMotorsWeb.VehicleHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form id="upload-form" phx-target={@myself} phx-change="validate" phx-submit="save">
        <h2 class="block text-sm font-semibold leading-6 text-zinc-200 pt-4">Images</h2>
        <span class="w-full flex flex-col sm:flex-row justify-between items-center px-4 pt-3 gap-4 m-4">
          <label for={@uploads.covers.ref} phx-drop-target={@uploads.covers.ref}>
            Drop a file or <.live_file_input upload={@uploads.covers} />
          </label>
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

      <section id="cover-entries">
        <article
          :for={{ref, cover} <- @covers}
          class="p-4 bg-zinc-800/50 rounded-3xl border border-zinc-600 flex flex-col items-center shadow-xl my-8"
        >
          <button
            type="button"
            phx-click="delete-cover"
            phx-value-ref={ref}
            aria-label="cancel"
            class="w-full text-right text-lg hover:text-red-400"
            phx-target={@myself}
          >
            &times;
          </button>
          <figure class="w-full flex flex-col items-center px-2">
            <img class="rounded-xl m-2 border border-zinc-500 shadow" src={Cover.url(cover)} />
            <figcaption
              title={cover}
              class="max-sm:text-sm flex flex-col sm:flex-row justify-between items-center px-8 py-2 gap-3"
            >
              <p title={cover}>{shorten_text(cover, 13)}</p>
            </figcaption>
          </figure>
        </article>
      </section>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:covers, %{})
     |> allow_upload(:covers,
       accept: ~w(.png .jpg .jpeg .avif),
       max_entries: 10,
       auto_upload: true,
       progress: &handle_progress/3
     )}
  end

  @impl true
  def update(%{:data => {:finish_image_processing, ref, cover}}, socket) do
    covers = Map.put(socket.assigns.covers, ref, cover)

    send_update(socket.assigns.parent, covers: to_waffle_ecto_type_array(covers))

    send(self(), {:put_flash, [:info, "Image Processing Completed!"]})

    {:ok, assign(socket, :covers, covers)}
  end

  defp to_waffle_ecto_type_array(covers) do
    Map.values(covers)
    |> Enum.map(fn cover ->
      %{file_name: cover, updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)}
    end)
  end

  def update(assigns, socket), do: {:ok, assign(socket, assigns)}

  defp handle_progress(:covers, %{:done? => true} = entry, socket) do
    pid = self()

    Task.async(fn ->
      cover =
        consume_uploaded_entry(socket, entry, fn %{} = meta ->
          cover = %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: meta.path
          }

          Cover.store({cover, socket.assigns.vehicle})
        end)

      send_update(pid, socket.assigns.myself, data: {:finish_image_processing, entry.ref, cover})
    end)

    send(pid, {:put_flash, [:info, "Image uploaded - Starting Processing..."]})

    {:noreply, socket}
  end

  defp handle_progress(:covers, _entry, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply,
     socket
     |> delete_cover(ref)
     |> cancel_upload(:covers, ref)}
  end

  def handle_event("delete-cover", %{"ref" => ref}, socket) do
    cover = Map.get(socket.assigns.covers, ref)

    if cover do
      Task.async(fn ->
        Cover.delete({cover, socket.assigns.vehicle})
      end)
    end

    socket = delete_cover(socket, ref)

    send_update(socket.assigns.parent, covers: to_waffle_ecto_type_array(socket.assigns.covers))

    {:noreply, socket}
  end

  defp delete_cover(socket, ref) do
    covers = Map.delete(socket.assigns.covers, ref)

    socket
    |> assign(:covers, covers)
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:external_client_failure), do: "Something went terribly wrong"
  defp error_to_string({:writer_failiure, reason}), do: "Failed writing image - #{reason}"
end
