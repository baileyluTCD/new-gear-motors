defmodule NextGearMotors.ReservationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NextGearMotors.Reservations` context.
  """

  alias NextGearMotors.Reservations
  import NextGearMotors.AccountsFixtures
  import NextGearMotors.VehiclesFixtures

  @doc """
  Generate a reservation.
  """
  def reservation_fixture(attrs \\ %{}) do
    user = Map.get(attrs, :user, user_fixture())
    vehicle = Map.get(attrs, :vehicle, vehicle_fixture())

    {:ok, reservation} =
      attrs
      |> Enum.into(%{
        planned_meeting_time: ~N[2025-05-19 21:58:00],
        status: :denied,
        user_id: user.id,
        vehicle_id: vehicle.id
      })
      |> Reservations.create_reservation()

    reservation
  end
end
