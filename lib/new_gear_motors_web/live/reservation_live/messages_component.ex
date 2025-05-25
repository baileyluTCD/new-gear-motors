defmodule NewGearMotorsWeb.ReservationLive.MessagesComponent do
  require Logger
  use NewGearMotorsWeb, :live_component

  alias Phoenix.PubSub

  alias NewGearMotors.Reservations
  alias NewGearMotors.Reservations.Messages
  alias NewGearMotors.Reservations.Messages.Message

  @impl true
  def update(%{event: {:delete, message}}, socket) do
    {:ok, stream_delete(socket, :messages, message)}
  end

  def update(%{event: {:new, message}}, socket) do
    {:ok, stream_insert(socket, :messages, message)}
  end

  def update(%{event: {:edit, message}}, socket) do
    {:ok, stream_insert(socket, :messages, message)}
  end

  def update(%{id: id} = assigns, socket) do
    messages = Messages.list_messages_for_reservation_id(id)

    empty_message = %Message{}

    {:ok,
     socket
     |> assign(assigns)
     |> stream(:messages, messages)
     |> assign(:message, empty_message)
     |> assign_new(:form, fn ->
       to_form(Messages.change_message(empty_message))
     end)}
  end

  @impl true
  def handle_event("delete_message", %{"message_id" => message_id}, socket) do
    message = Messages.get_message!(message_id)
    {:ok, _} = Messages.delete_message(message)

    Phoenix.PubSub.broadcast(
      NewGearMotors.PubSub,
      "messages:#{socket.assigns.id}",
      {:delete, message}
    )

    {:noreply, stream_delete(socket, :messages, message)}
  end

  def handle_event(event, %{"message" => message_params}, socket) do
    message_params =
      Map.merge(message_params, %{
        "from_id" => socket.assigns.current_user.id,
        "reservation_id" => socket.assigns.reservation.id
      })

    handle_with_defaults(event, message_params, socket)
  end

  defp handle_with_defaults("validate", message_params, socket) do
    changeset = Messages.change_message(socket.assigns.message, message_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  defp handle_with_defaults("save", message_params, socket) do
    save_message(socket, socket.assigns.action, message_params)
  end

  defp save_message(socket, :show, message_params) do
    case Messages.create_message(message_params) do
      {:ok, message} ->
        message = message |> Messages.preload_from()

        Phoenix.PubSub.broadcast(
          NewGearMotors.PubSub,
          "messages:#{socket.assigns.id}",
          {:new, message}
        )

        {:noreply,
         socket =
           socket
           |> put_flash(:info, "Message sent successfully")
           |> push_patch(to: socket.assigns.patch)
           |> stream_insert(:messages, message)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
