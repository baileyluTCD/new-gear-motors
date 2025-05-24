defmodule NewGearMotorsWeb.ReservationLive.MessagesComponent do
  use NewGearMotorsWeb, :live_component

  alias NewGearMotors.Reservations
  alias NewGearMotors.Reservations.Messages
  alias NewGearMotors.Reservations.Messages.Message

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-md font-semibold leading-8 text-zinc-800 mt-10">
        Messages
      </h2>

      <.table id="messages" rows={@messages}>
        <:col :let={{_id, message}} label="From">{message.from}</:col>
        <:col :let={{_id, message}} label="Body">{message.text}</:col>
        <:action :let={{_id, message}}>
          <.link patch={~p"/reservations/#{@reservation}/messages/#{message}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, message}}>
          <.link
            phx-click={JS.push("delete_message", value: %{message_id: message.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>

      <.simple_form
        for={@form}
        id="messages-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:text]} placeholder="Message..." />
        <:actions>
          <.button phx-disable-with="Sending...">Send Message</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{messages: messages} = assigns, socket) do
    message = %Message{}

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

  defp save_message(socket, :edit, message_params) do
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

  defp save_message(socket, :new, message_params) do
    case Messages.create_message(message_params) do
      {:ok, message} ->
        notify_parent({:saved, message})

        {:noreply,
         socket
         |> put_flash(:info, "Message sent successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
