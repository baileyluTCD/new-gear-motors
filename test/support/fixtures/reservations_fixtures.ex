defmodule NewGearMotors.ReservationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NewGearMotors.Reservations` context.
  """

  alias NewGearMotors.Reservations

  @doc """
  Generate a reservation.
  """
  def reservation_fixture(attrs \\ %{}) do
    {:ok, reservation} =
      attrs
      |> Enum.into(%{
        planned_meeting_time: ~N[2025-05-19 21:58:00],
        status: :denied
      })
      |> Reservations.create_reservation()

    reservation
  end
end
