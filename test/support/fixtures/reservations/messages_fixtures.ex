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
    {:ok, message} =
      attrs
      |> Enum.into(%{
        text: "some text",
        from: AccountsFixtures.user_fixture(),
        reservation: ReservationsFixtures.reservation_fixture()
      })
      |> NewGearMotors.Reservations.Messages.create_message()

    message
  end
end
