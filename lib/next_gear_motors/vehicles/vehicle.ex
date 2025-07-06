defmodule NextGearMotors.Vehicles.Vehicle do
  @moduledoc """
  # Vehicle Schema

  The type and constraints for a vehicle, the primary object sold in the store
  """

  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "vehicles" do
    field :name, :string
    field :description, :string
    field :price, :string
    field :manufacturer, :string
    field :cover, NextGearMotors.Vehicles.Covers.Cover.Type
    has_many :reservations, NextGearMotors.Reservations.Reservation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:name, :price, :description, :manufacturer, :cover])
    |> cast_attachments(attrs, [:cover])
    |> validate_required([:name, :price, :description, :manufacturer, :cover])
    |> validate_format(:price, ~r/^€[0-9|,]*/,
      message: "price must be a number in euro - i.e. '€20,000'"
    )
  end
end
