defmodule NewGearMotorsWeb.ReservationLive.MessagesFormComponent do
  require Logger
  use NewGearMotorsWeb, :live_component

  alias NewGearMotors.Reservations.Messages

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage message records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="messages-edit-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:text]}
          type="text"
          label="Body"
          placeholder="Message..."
          value={@message.text}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Message</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{message_id: message_id} = assigns, socket) do
    message = Messages.get_message!(message_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:message, message)
     |> assign_new(:form, fn ->
       to_form(Messages.change_message(message))
     end)}
  end

  @impl true
  def handle_event("validate", %{"message" => message_params}, socket) do
    changeset = Messages.change_message(socket.assigns.message, message_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"message" => message_params}, socket) do
    save_message(socket, socket.assigns.action, message_params)
  end

  defp save_message(socket, :edit_message, message_params) do
    case Messages.update_message(socket.assigns.message, message_params) do
      {:ok, message} ->
        notify_parent({:saved, message})

        {:noreply,
         socket
         |> put_flash(:info, "Message updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
