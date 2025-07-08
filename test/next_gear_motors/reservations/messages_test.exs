defmodule NextGearMotors.Reservations.MessagesTest do
  use NextGearMotors.DataCase

  alias NextGearMotors.Reservations.Messages

  describe "messages" do
    alias NextGearMotors.Reservations.Messages.Message

    import NextGearMotors.Reservations.MessagesFixtures
    alias NextGearMotors.ReservationsFixtures
    alias NextGearMotors.AccountsFixtures

    setup do
      user = AccountsFixtures.user_fixture()
      reservation = ReservationsFixtures.reservation_fixture()

      {:ok,
       %{
         valid_attrs: %{
           text: "some text",
           from_id: user.id,
           reservation_id: reservation.id
         },
         invalid_attrs: %{
           text: nil,
           from_id: nil,
           reservation_id: nil
         },
         user: user,
         reservation: reservation
       }}
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Messages.list_messages() == [message]
    end

    test "list_messages_for_reservation_id/1 returns messages for the reservation", %{
      valid_attrs: valid_attrs,
      reservation: reservation
    } do
      assert {:ok, %Message{} = message} = Messages.create_message(valid_attrs)

      [for_id] = Messages.list_messages_for_reservation_id(reservation.id)

      assert for_id.id == message.id
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messages.get_message!(message.id) == message
    end

    test "preload_from/1 returns the message with given id", %{
      valid_attrs: valid_attrs,
      user: user
    } do
      assert {:ok, %Message{} = message} = Messages.create_message(valid_attrs)

      with_from =
        Messages.get_message!(message.id)
        |> Messages.preload_from()

      assert with_from.from.email == user.email
    end

    test "create_message/1 with valid data creates a message", %{valid_attrs: valid_attrs} do
      assert {:ok, %Message{} = message} = Messages.create_message(valid_attrs)
      assert message.text == "some text"
    end

    test "create_message/1 stops working after 25 messages", %{valid_attrs: valid_attrs} do
      for x <- 0..24 do
        assert {:ok, %Message{}} = Messages.create_message(valid_attrs)
      end

      assert {:error, %Ecto.Changeset{}} = Messages.create_message(valid_attrs)
    end

    test "create_message/1 with invalid data returns error changeset", %{
      invalid_attrs: invalid_attrs
    } do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{text: "some updated text"}

      assert {:ok, %Message{} = message} = Messages.update_message(message, update_attrs)
      assert message.text == "some updated text"
    end

    test "update_message/2 with invalid data returns error changeset", %{
      invalid_attrs: invalid_attrs
    } do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messages.update_message(message, invalid_attrs)
      assert message == Messages.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messages.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messages.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messages.change_message(message)
    end
  end
end
