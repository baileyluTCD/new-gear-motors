defmodule NewGearMotors.Reservations.MessagesTest do
  use NewGearMotors.DataCase

  alias NewGearMotors.Reservations.Messages

  describe "messages" do
    alias NewGearMotors.Reservations.Messages.Message

    import NewGearMotors.Reservations.MessagesFixtures
    alias NewGearMotors.ReservationsFixtures
    alias NewGearMotors.AccountsFixtures

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
         }
       }}
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Messages.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messages.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message", %{valid_attrs: valid_attrs} do
      assert {:ok, %Message{} = message} = Messages.create_message(valid_attrs)
      assert message.text == "some text"
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
