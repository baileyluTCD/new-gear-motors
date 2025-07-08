defmodule NextGearMotorsWeb.ReservationLive.FormComponent do
  use NextGearMotorsWeb, :live_component

  alias NextGearMotors.Reservations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title} -
        <.link class="hover:underline" patch={~p"/vehicles/#{@vehicle}"}>{@vehicle.name}</.link>
        <:subtitle>Use this form to manage reservations for "{@vehicle.name}".</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="reservation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:planned_meeting_time]}
          type="datetime-local"
          label="Proposed meeting time"
        />
        <.input
          :if={@current_user.is_admin}
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a value"
          options={Ecto.Enum.values(NextGearMotors.Reservations.Reservation, :status)}
        />
        <.input field={@form[:existing_count]} type="hidden" />
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
    reservation_params =
      reservation_params
      |> put_default_reservation_params(socket)

    changeset = Reservations.change_reservation(socket.assigns.reservation, reservation_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"reservation" => reservation_params}, socket) do
    reservation_params =
      reservation_params
      |> put_default_reservation_params(socket)

    save_reservation(socket, socket.assigns.action, reservation_params)
  end

  defp put_default_reservation_params(reservation_params, socket) do
    reservation_params =
      reservation_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("vehicle_id", socket.assigns.vehicle.id)

    if socket.assigns.current_user.is_admin do
      reservation_params
    else
      reservation_params
      |> Map.put("status", :pending)
    end
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
