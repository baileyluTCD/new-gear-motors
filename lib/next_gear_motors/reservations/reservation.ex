defmodule NextGearMotors.Reservations.Reservation do
  @moduledoc """
  # Reservation Schema

  The database type for a given reservation
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias NextGearMotors.Accounts

  @max_reservations_per_user 3

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reservations" do
    field :status, Ecto.Enum, values: [:denied, :pending, :accepted]
    field :planned_meeting_time, :naive_datetime
    belongs_to :user, NextGearMotors.Accounts.User
    belongs_to :vehicle, NextGearMotors.Vehicles.Vehicle
    has_many :messages, NextGearMotors.Reservations.Messages.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:status, :planned_meeting_time, :user_id, :vehicle_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:vehicle)
    |> validate_required([:status, :planned_meeting_time, :user_id, :vehicle_id])
    |> validate_reservation_limit()
  end

  defp validate_reservation_limit(reservation) do
    case fetch_field(reservation, :user_id) do
      {_, nil} ->
        add_error(
          reservation,
          :existing_count,
          "this user id is invalid hence a maximum owned cannot be applied"
        )

      {_, user_id} ->
        check_count(reservation, user_id)

      _ ->
        add_error(
          reservation,
          :existing_count,
          "this reservation does not have a user id associated with it and hence a maximum owned cannot be applied"
        )
    end
  end

  defp check_count(reservation, user_id) do
    count = Accounts.count_reservations_for_id(user_id)

    if count < @max_reservations_per_user do
      reservation
    else
      reservation
      |> add_error(
        :existing_count,
        "you already have the maximum number of concurrent reservations (#{@max_reservations_per_user}) - please delete some or wait for them to be resolved"
      )
    end
  end
end
