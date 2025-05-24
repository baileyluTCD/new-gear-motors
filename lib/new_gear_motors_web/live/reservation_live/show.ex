defmodule NewGearMotorsWeb.ReservationLive.Show do
  use NewGearMotorsWeb, :live_view

  alias NewGearMotors.Reservations
  alias NewGearMotors.Reservations.Messages

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    reservation =
      Reservations.get_reservation!(id)
      |> Reservations.preload_messages()

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:reservation, reservation)
      |> stream(:messages, reservation.messages)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params), do: socket
  defp apply_action(socket, :edit, _params), do: socket

  defp apply_action(socket, :edit_message, %{"message_id" => message_id}) do
    message = Messages.get_message!(message_id)

    socket
    |> assign(:message, message)
  end

  @impl true
  def handle_event("delete_message", %{"message_id" => message_id}, socket) do
    message = Messages.get_message!(message_id)
    {:ok, _} = Messages.delete_message(message)

    {:noreply, stream_delete(socket, :messages, message)}
  end

  @impl true
  def handle_event("new_message", %{"message_text" => message_text}, socket) do
    {:ok, message} =
      Messages.create_message(%{
        text: message_text,
        from_id: socket.assigns.current_user.id,
        reservation_id: socket.assigns.reservation.id
      })

    {:noreply, stream_insert(socket, :messages, message)}
  end

  defp page_title(:show), do: "Show Reservation"
  defp page_title(:edit), do: "Edit Reservation"
  defp page_title(:new_message), do: "New Message"
  defp page_title(:edit_message), do: "Edit Message"
end
