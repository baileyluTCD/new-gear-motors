defmodule NewGearMotorsWeb.ReservationLive.Show do
  use NewGearMotorsWeb, :live_view

  alias NewGearMotors.Reservations
  alias NewGearMotors.Reservations.Messages

  require Logger

  on_mount {NewGearMotorsWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    reservation = Reservations.get_reservation!(id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:reservation, reservation)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket = socket |> assign(:message_id, nil)

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
