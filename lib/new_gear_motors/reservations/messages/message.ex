defmodule NewGearMotors.Reservations.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :text, :string
    belongs_to :from, NewGearMotors.Accounts.User
    belongs_to :reservation, NewGearMotors.Reservations.Reservation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(messages, attrs) do
    messages
    |> cast(attrs, [:text, :from_id, :reservation_id])
    |> assoc_constraint(:from)
    |> assoc_constraint(:reservation)
    |> validate_required([:text, :from_id, :reservation_id])
    |> validate_length(:text, min: 1, max: 500)
  end
end
