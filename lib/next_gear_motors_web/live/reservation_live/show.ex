defmodule NextGearMotorsWeb.ReservationLive.Show do
  use NextGearMotorsWeb, :live_view
  alias NextGearMotorsWeb.ReservationLive.MessagesComponent

  alias Phoenix.PubSub

  alias NextGearMotors.Reservations

  on_mount {NextGearMotorsWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    reservation =
      Reservations.get_reservation!(id)
      |> Reservations.preload_vehicle()
      |> Reservations.preload_user()

    PubSub.subscribe(NextGearMotors.PubSub, "messages:#{id}")

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:reservation, reservation)
      |> assign(:vehicle, reservation.vehicle)
      |> assign(:owner, reservation.user)

    {:ok, socket}
  end

  @impl true
  def handle_info(
        {NextGearMotorsWeb.ReservationLive.FormComponent, {:saved, reservation}},
        socket
      ) do
    {:noreply, assign(socket, :reservation, reservation)}
  end

  def handle_info(event, socket) do
    send_update(MessagesComponent, id: socket.assigns.reservation.id, event: event)
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> assign(:message_id, nil)
      |> assign(:page_title, page_title(socket.assigns.live_action))

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params), do: socket
  defp apply_action(socket, :edit, _params), do: socket

  defp apply_action(socket, :edit_message, params) do
    socket
    |> assign(:message_id, params["message_id"])
  end

  defp page_title(:show), do: "Show Reservation"
  defp page_title(:edit), do: "Edit Reservation"
  defp page_title(:edit_message), do: "Edit Message"
end
