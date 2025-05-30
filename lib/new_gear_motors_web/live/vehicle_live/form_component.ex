defmodule NewGearMotorsWeb.VehicleLive.FormComponent do
  use NewGearMotorsWeb, :live_component

  alias NewGearMotors.Vehicles

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage vehicle records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="vehicle-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.live_file_input upload={@uploads.image} />
        <img :if={@image_url} src={@image_url} />
        <.error :if={@image_url_error}>
          {@image_url_error}
        </.error>
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:price]} type="text" label="Price" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:manufacturer]} type="text" label="Manufacturer" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Vehicle</.button>
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
     |> allow_upload(:image,
       accept: ~w(.png .jpg .jpeg),
       max_entries: 1,
       progress: &handle_progress/3,
       auto_upload: true
     )
     |> assign(:image_url, nil)
     |> assign(:image_url_error, nil)
     |> assign_new(:form, fn ->
       to_form(Vehicles.change_vehicle(vehicle))
     end)}
  end

  defp handle_progress(:image, entry, socket) do
    if entry.done? do
      uploaded_file =
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          dest = Path.join("priv/static/uploads", Path.basename(path))
          File.cp!(path, dest)
          {:ok, dest}
        end)

      basename = Path.basename(uploaded_file)

      socket =
        socket
        |> put_flash(:info, "File #{basename} uploaded")
        |> assign(:image_url, ~p"/uploads/#{basename}")

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"vehicle" => vehicle_params}, socket) do
    {socket, vehicle_params} = inject_image(socket, vehicle_params)

    changeset = Vehicles.change_vehicle(socket.assigns.vehicle, vehicle_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"vehicle" => vehicle_params}, socket) do
    {socket, vehicle_params} = inject_image(socket, vehicle_params)

    save_vehicle(socket, socket.assigns.action, vehicle_params)
  end

  defp inject_image(socket, vehicle_params) do
    if socket.assigns.image_url do
      vehicle_params =
        Map.merge(vehicle_params, %{
          "image_url" => socket.assigns.image_url
        })

      socket =
        socket
        |> assign(:image_url_error, nil)

      {socket, vehicle_params}
    else
      socket =
        socket
        |> assign(:image_url_error, "image is required")

      {socket, vehicle_params}
    end
  end

  defp save_vehicle(socket, :edit, vehicle_params) do
    case Vehicles.update_vehicle(socket.assigns.vehicle, vehicle_params) do
      {:ok, vehicle} ->
        notify_parent({:saved, vehicle})

        {:noreply,
         socket
         |> put_flash(:info, "Vehicle updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_vehicle(socket, :new, vehicle_params) do
    case Vehicles.create_vehicle(vehicle_params) do
      {:ok, vehicle} ->
        notify_parent({:saved, vehicle})

        {:noreply,
         socket
         |> put_flash(:info, "Vehicle created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
