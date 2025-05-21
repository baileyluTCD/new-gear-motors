defmodule NewGearMotors.Reservations.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NewGearMotors.Reservations.Messages` context.
  """
  alias NewGearMotors.AccountsFixtures
  alias NewGearMotors.ReservationsFixtures

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()
    reservation = ReservationsFixtures.reservation_fixture()

    {:ok, message} =
      attrs
      |> Enum.into(%{
        text: "some text",
        from_id: user.id,
        reservation_id: reservation.id
      })
      |> NewGearMotors.Reservations.Messages.create_message()

    message
  end
end
