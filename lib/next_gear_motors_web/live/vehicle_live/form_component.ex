defmodule NextGearMotorsWeb.VehicleLive.FormComponent do
  use NextGearMotorsWeb, :live_component

  alias NextGearMotors.Vehicles
  alias NextGearMotors.Vehicles.Covers.Cover

  import NextGearMotorsWeb.VehicleHelper


  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          Use this form to manage vehicle records in your database. Note that uploading a new batch of images overwrites the old one.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="vehicle-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <h2 class="block text-sm font-semibold leading-6 text-zinc-200">Images</h2>
        <button phx-click="clear-existing-covers" phx-target={@myself}>
          <.live_file_input phx-change="clear-existing-covers" upload={@uploads.covers} />
        </button>

        <article
          :for={{_ref, entry} <- @in_progress}
          class="p-4 bg-zinc-800/50 rounded-3xl border border-zinc-600 flex flex-row justify-between items-center shadow-xl my-8 gap-4"
        >
          <p title={entry.client_name}>{shorten_text(entry.client_name, 13)}</p>
          <progress
            title={"File Upload - #{entry.progress}%"}
            value={entry.progress}
            max="100"
            class="w-full rounded-lg animate-pulse"
          >
            {entry.progress}%
          </progress>
        </article>

        <article
          :for={entry <- @uploads.covers.entries}
          :if={entry.done?}
          class="p-4 bg-zinc-800/50 rounded-3xl border border-zinc-600 flex flex-col items-center shadow-xl my-8"
        >
          <figure class="w-full flex flex-col items-center px-2">
            <.live_img_preview entry={entry} class="rounded-xl m-2 border border-zinc-500 shadow" />
            <figcaption
              title={entry.client_name}
              class="max-sm:text-sm flex flex-col sm:flex-row justify-between items-center px-8 py-2 gap-3"
            >
              {entry.client_name}
            </figcaption>
          </figure>
        </article>

        <%= if err = @form.errors[:covers] do %>
          <%= if {msg, _} = err do %>
            <.error>{msg}</.error>
          <% end %>
        <% end %>

        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:price]} type="text" label="Price" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:manufacturer]} type="text" label="Manufacturer" />
        <:actions>
          <.button phx-disable-with="Saving and Compressing Images...">Save Vehicle</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{vehicle: vehicle} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> allow_upload(:covers,
       accept: ~w(.png .jpg .jpeg .avif),
       max_entries: 20,
       auto_upload: true,
       progress: &handle_progress/3
     )
     |> assign(:covers, vehicle.covers || [])
     |> assign(:in_progress, %{})
     |> assign_new(:form, fn ->
       to_form(Vehicles.change_vehicle(vehicle))
     end)}
  end

  defp handle_progress(:covers, %{:done? => true} = entry, socket) do
    covers = [consume_cover(socket, entry) | socket.assigns.covers]

    socket =
      socket
      |> put_flash(:info, "Image uploaded!")
      |> assign(:covers, covers)
      |> assign(:in_progress, Map.delete(socket.assigns.in_progress, entry.uuid))

    {_, socket} = handle_event("validate", %{"vehicle" => socket.assigns.form.params}, socket)

    {:noreply, socket}
  end

  defp handle_progress(:covers, entry, socket) do
    socket =
      socket
      |> assign(:in_progress, Map.put(socket.assigns.in_progress, entry.uuid, entry))

    {:noreply, socket}
  end

  defp consume_cover(socket, entry) do
    consume_uploaded_entry(socket, entry, fn %{} = meta ->
      cover = %Plug.Upload{
        content_type: entry.client_type,
        filename: entry.client_name,
        path: meta.path
      }

      {:postpone, cover}
    end)
  end

  defp with_covers(params, socket) do
    if Enum.any?(socket.assigns.covers, fn cover -> Map.has_key?(cover, :file_name) end) do
      params
    else
      Map.put(params, "covers", socket.assigns.covers)
    end
  end

  @impl true
  def handle_event("validate", %{"vehicle" => vehicle_params}, socket) do
    vehicle_params = with_covers(vehicle_params, socket)

    changeset = Vehicles.change_vehicle(socket.assigns.vehicle, vehicle_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"vehicle" => vehicle_params}, socket) do
    vehicle_params = with_covers(vehicle_params, socket)

    save_vehicle(socket, socket.assigns.action, vehicle_params)
  end

  def handle_event("clear-existing-covers", _value, socket) do
    {:noreply, assign(socket, :covers, [])}
  end

  defp save_vehicle(socket, :edit, vehicle_params),
    do:
      Vehicles.update_vehicle(socket.assigns.vehicle, vehicle_params)
      |> notify_saved("Vehicle updated successfully", socket)

  defp save_vehicle(socket, :new, vehicle_params),
    do:
      Vehicles.create_vehicle(vehicle_params)
      |> notify_saved("Vehicle created successfully", socket)

  defp notify_saved({:ok, vehicle}, msg, socket) do
    notify_parent({:saved, vehicle})

    {:noreply,
     socket
     |> put_flash(:info, msg)
     |> push_navigate(to: socket.assigns.patch)}
  end

  defp notify_saved({:error, %Ecto.Changeset{} = changeset}, _, socket),
    do: {:noreply, assign(socket, form: to_form(changeset))}

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
