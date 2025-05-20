defmodule NewGearMotors.Vehicles.Vehicle do
  @moduledoc """
  # Vehicle Schema

  The type and constraints for a vehicle
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "vehicles" do
    field :name, :string
    field :description, :string
    field :price, :string
    field :manufacturer, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:name, :price, :description, :manufacturer])
    |> validate_required([:name, :price, :description, :manufacturer])
  end
end
