defmodule NewGearMotorsWeb.ReservationLive.FormComponent do
  use NewGearMotorsWeb, :live_component

  alias NewGearMotors.Reservations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage reservation records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="reservation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a value"
          options={Ecto.Enum.values(NewGearMotors.Reservations.Reservation, :status)}
        />
        <.input field={@form[:planned_meeting_time]} type="datetime-local" label="Planned meeting time" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Reservation</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{reservation: reservation} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Reservations.change_reservation(reservation))
     end)}
  end

  @impl true
  def handle_event("validate", %{"reservation" => reservation_params}, socket) do
    changeset = Reservations.change_reservation(socket.assigns.reservation, reservation_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"reservation" => reservation_params}, socket) do
    save_reservation(socket, socket.assigns.action, reservation_params)
  end

  defp save_reservation(socket, :edit, reservation_params) do
    case Reservations.update_reservation(socket.assigns.reservation, reservation_params) do
      {:ok, reservation} ->
        notify_parent({:saved, reservation})

        {:noreply,
         socket
         |> put_flash(:info, "Reservation updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_reservation(socket, :new, reservation_params) do
    case Reservations.create_reservation(reservation_params) do
      {:ok, reservation} ->
        notify_parent({:saved, reservation})

        {:noreply,
         socket
         |> put_flash(:info, "Reservation created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
