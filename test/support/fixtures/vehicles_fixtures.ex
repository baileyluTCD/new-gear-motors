defmodule NewGearMotors.VehiclesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NewGearMotors.Vehicles` context.
  """

  @doc """
  Generate a vehicle.
  """
  def vehicle_fixture(attrs \\ %{}) do
    {:ok, vehicle} =
      attrs
      |> Enum.into(%{
        description: "some description",
        manufacturer: "some manufacturer",
        name: "some name",
        price: "some price"
      })
      |> NewGearMotors.Vehicles.create_vehicle()

    vehicle
  end
end
