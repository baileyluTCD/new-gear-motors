defmodule NextGearMotorsWeb.VehicleLive.FormComponent do
  use NextGearMotorsWeb, :live_component

  alias NextGearMotors.Vehicles
  alias NextGearMotors.Vehicles.Covers.Cover

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
        <.live_file_input upload={@uploads.cover} />

        <%= if cover = @form[:cover].value do %>
          <img src={Cover.url(cover)} alt="Previous Image" />
        <% end %>

        <%= if err = @form.errors[:cover] do %>
          <%= if {msg, _} = err do %>
            <.error>{msg}</.error>
          <% end %>
        <% end %>

        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:price]} type="text" label="Price" />
        <.input field={@form[:description]} type="textarea" label="Description" />
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
     |> allow_upload(:cover,
       accept: ~w(.png .jpg .jpeg .avif),
       max_entries: 1,
       auto_upload: true,
       progress: &handle_progress/3
     )
     |> assign_new(:form, fn ->
       to_form(Vehicles.change_vehicle(vehicle))
     end)}
  end

  defp handle_progress(:cover, entry, socket) do
    if entry.done? do
      vehicle_params =
        socket.assigns.form.params
        |> with_cover(socket)

      socket =
        socket
        |> put_flash(:info, "Image uploaded")
        |> assign(
          :form,
          Map.put(socket.assigns.form, "cover", vehicle_params["cover"])
        )

      {_, socket} = handle_event("validate", %{"vehicle" => vehicle_params}, socket)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"vehicle" => vehicle_params}, socket) do
    vehicle_params =
      vehicle_params
      |> with_cover(socket)

    changeset = Vehicles.change_vehicle(socket.assigns.vehicle, vehicle_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"vehicle" => vehicle_params}, socket) do
    vehicle_params =
      vehicle_params
      |> with_cover(socket)

    socket
    |> save_vehicle(socket.assigns.action, vehicle_params)
  end

  defp with_cover(vehicle_params, socket) do
    if socket.assigns.uploads.cover.entries |> Enum.any?(&(!&1.done?)) do
      vehicle_params
    else
      entries =
        consume_uploaded_entries(socket, :cover, fn meta, entry ->
          cover = %Plug.Upload{
            content_type: entry.client_type,
            filename: entry.client_name,
            path: meta.path
          }

          updated_params = Map.put(vehicle_params, "cover", cover)
          {:postpone, updated_params}
        end)

      case entries do
        [vehicle_params] -> vehicle_params
        _ -> vehicle_params
      end
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
