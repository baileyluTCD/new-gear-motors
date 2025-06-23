defmodule NextGearMotors.Reservations.Reservation do
  @moduledoc """
  # Reservation Schema

  The database type for a given reservation
  """

  use Ecto.Schema
  import Ecto.Changeset

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
  end
end
