defmodule NewGearMotorsWeb.VehicleLive.Index do
  use NewGearMotorsWeb, :live_view

  alias NewGearMotors.Vehicles
  alias NewGearMotors.Vehicles.Vehicle

  import NewGearMotorsWeb.VehicleHelper

  alias NewGearMotors.Vehicles.Covers.Cover

  on_mount {NewGearMotorsWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :vehicles, Vehicles.list_vehicles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    if socket.assigns.current_user.is_admin do
      socket
      |> assign(:page_title, "Edit Vehicle")
      |> assign(:vehicle, Vehicles.get_vehicle!(id))
    else
      socket
      |> put_flash(:error, "You must be an admin to access this resource.")
      |> push_patch(to: ~p"/vehicles")
    end
  end

  defp apply_action(socket, :new, _params) do
    if socket.assigns.current_user.is_admin do
      socket
      |> assign(:page_title, "New Vehicle")
      |> assign(:vehicle, %Vehicle{})
    else
      socket
      |> put_flash(:error, "You must be an admin to access this resource.")
      |> push_patch(to: ~p"/vehicles")
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Vehicles")
    |> assign(:vehicle, nil)
  end

  @impl true
  def handle_info({NewGearMotorsWeb.VehicleLive.FormComponent, {:saved, vehicle}}, socket) do
    {:noreply, stream_insert(socket, :vehicles, vehicle)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if socket.assigns.current_user.is_admin do
      vehicle = Vehicles.get_vehicle!(id)
      {:ok, _} = Vehicles.delete_vehicle(vehicle)

      {:noreply, stream_delete(socket, :vehicles, vehicle)}
    else
      {:noreply, put_flash(socket, :error, "You must be an admin to access this resource.")}
    end
  end
end
