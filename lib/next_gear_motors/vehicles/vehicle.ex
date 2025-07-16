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
    field :covers, {:array, NextGearMotors.Vehicles.Covers.Cover.Type}
    has_many :reservations, NextGearMotors.Reservations.Reservation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def save_changeset(vehicle, attrs) do
    vehicle
    |> validate_changeset(attrs)
    |> validate_covers(attrs)
  end

  def validate_changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:name, :price, :description, :manufacturer])
    |> validate_required([:name, :price, :description, :manufacturer])
    |> validate_format(:price, ~r/^€[0-9|,|.]*/,
      message: "price must be a number in euro - i.e. '€19,999.99'"
    )
  end

  def validate_covers(vehicle, attrs) do
    vehicle
    |> cast_attachments(attrs, ~w(covers)a)
    |> validate_required([:covers])
    |> validate_length(:covers, min: 1, max: 20)
  end
end
