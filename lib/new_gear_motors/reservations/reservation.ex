defmodule NewGearMotors.Reservations.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reservations" do
    field :status, Ecto.Enum, values: [:denied, :pending, :accepted]
    field :planned_meeting_time, :naive_datetime
    belongs_to :user, NewGearMotors.Accounts.User
    has_many :messages, NewGearMotors.Reservations.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:status, :planned_meeting_time])
    |> validate_required([:status, :planned_meeting_time])
  end
end
