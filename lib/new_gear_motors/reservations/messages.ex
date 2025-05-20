defmodule NewGearMotors.Reservations.Messages do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :text, :string
    belongs_to :from, YourApp.Accounts.User
    belongs_to :to, YourApp.Accounts.User
    belongs_to :reservation, YourApp.Reservations.Reservation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(messages, attrs) do
    messages
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
