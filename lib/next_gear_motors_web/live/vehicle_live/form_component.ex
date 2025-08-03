defmodule NextGearMotorsWeb.VehicleLive.FormComponent do
  use NextGearMotorsWeb, :live_component

  alias NextGearMotors.Vehicles
  alias NextGearMotorsWeb.VehicleLive.ImagesComponent

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

      <.live_component
        module={ImagesComponent}
        id={:images_form}
        parent={@myself}
        patch={@patch}
        vehicle={@vehicle}
      />
      <.error :for={err <- @form[:covers].errors}>{translate_error(err)}</.error>

      <.simple_form
        for={@form}
        id="vehicle-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
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
     |> assign(:covers, vehicle.covers)
     |> assign_new(:form, fn ->
       to_form(Vehicles.change_vehicle(vehicle))
     end)}
  end

  def update(%{:covers => covers}, socket) do
    {:ok, assign(socket, :covers, covers)}
  end

  @impl true
  def handle_event(event, %{"vehicle" => vehicle_params}, socket) do
    vehicle_params = Map.put(vehicle_params, "covers", Map.get(socket.assigns, :covers, []))
    handle_event_with_covers(event, vehicle_params, socket)
  end

  def handle_event_with_covers("validate", vehicle_params, socket) do
    changeset = Vehicles.change_vehicle(socket.assigns.vehicle, vehicle_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event_with_covers("save", vehicle_params, socket) do
    save_vehicle(socket, socket.assigns.action, vehicle_params)
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
     |> push_patch(to: socket.assigns.patch)}
  end

  defp notify_saved({:error, %Ecto.Changeset{} = changeset}, _, socket),
    do: {:noreply, assign(socket, form: to_form(changeset))}

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
