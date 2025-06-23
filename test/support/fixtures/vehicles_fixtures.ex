defmodule NextGearMotors.VehiclesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NextGearMotors.Vehicles` context.
  """

  @doc """
  Generate a vehicle.
  """
  def vehicle_fixture(attrs \\ %{}) do
    cover = %Plug.Upload{
      path: "test/support/fixtures/vehicles_fixtures/car.jpg",
      filename: "car.jpg",
      content_type: "image/jpeg"
    }

    {:ok, vehicle} =
      attrs
      |> Enum.into(%{
        description: "some description",
        manufacturer: "some manufacturer",
        name: "some name",
        price: "some price",
        cover: cover
      })
      |> NextGearMotors.Vehicles.create_vehicle()

    vehicle
  end
end
