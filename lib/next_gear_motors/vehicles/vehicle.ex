defmodule NextGearMotors.Vehicles.Vehicle do
  @moduledoc """
  # Vehicle Schema

  The type and constraints for a vehicle, the primary object sold in the store
  """

  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  alias NextGearMotors.Vehicles.Covers.Cover

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "vehicles" do
    field :name, :string
    field :description, :string
    field :price, :string
    field :manufacturer, :string
    field :covers, {:array, Cover.Type}, default: []
    has_many :reservations, NextGearMotors.Reservations.Reservation

    timestamps(type: :utc_datetime)
  end

  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:name, :covers, :price, :description, :manufacturer])
    |> validate_required([:name, :covers, :price, :description, :manufacturer])
    |> validate_format(:price, ~r/^€[0-9|,|\.]*$/,
      message: "must be a number in euro - i.e. '€19,999.99'"
    )
    |> validate_length(:covers, min: 1, max: 20)
  end
end
