defmodule NextGearMotors.ReservationsTest do
  use NextGearMotors.DataCase

  alias NextGearMotors.Reservations
  import NextGearMotors.AccountsFixtures
  import NextGearMotors.VehiclesFixtures

  describe "reservations" do
    alias NextGearMotors.Reservations.Reservation

    import NextGearMotors.ReservationsFixtures

    setup do
      user = confirmed_user_fixture()
      vehicle = vehicle_fixture()

      {:ok,
       %{
         valid_attrs: %{
           status: :denied,
           planned_meeting_time: ~N[2025-05-19 21:58:00],
           user_id: user.id,
           vehicle_id: vehicle.id
         },
         invalid_attrs: %{
           status: nil,
           planned_meeting_time: nil,
           user_id: nil,
           vehicle_id: nil
         },
         user: user
       }}
    end

    test "list_reservations/0 returns all reservations" do
      reservation = reservation_fixture()
      assert Reservations.list_reservations() == [reservation]
    end

    test "get_reservation!/1 returns the reservation with given id" do
      reservation = reservation_fixture()
      assert Reservations.get_reservation!(reservation.id) == reservation
    end

    test "create_reservation/1 with valid data creates a reservation", %{
      valid_attrs: valid_attrs
    } do
      assert {:ok, %Reservation{} = reservation} = Reservations.create_reservation(valid_attrs)
      assert reservation.status == :denied
      assert reservation.planned_meeting_time == ~N[2025-05-19 21:58:00]
    end

    test "create_reservation/1 with unconfirmed user fails", %{
      valid_attrs: valid_attrs
    } do
      unconfirmed_attrs = %{valid_attrs | user_id: user_fixture().id}

      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(unconfirmed_attrs)
    end

    test "create_reservation/1 more than 3 times for a user fails", %{
      valid_attrs: valid_attrs
    } do
      for _ <- 0..2 do
        assert {:ok, %Reservation{}} = Reservations.create_reservation(valid_attrs)
      end

      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(valid_attrs)
    end

    test "create_reservation/1 with invalid data returns error changeset", %{
      invalid_attrs: invalid_attrs
    } do
      assert {:error, %Ecto.Changeset{}} = Reservations.create_reservation(invalid_attrs)
    end

    test "update_reservation/2 with valid data updates the reservation" do
      reservation = reservation_fixture()
      update_attrs = %{status: :pending, planned_meeting_time: ~N[2025-05-20 21:58:00]}

      assert {:ok, %Reservation{} = reservation} =
               Reservations.update_reservation(reservation, update_attrs)

      assert reservation.status == :pending
      assert reservation.planned_meeting_time == ~N[2025-05-20 21:58:00]
    end

    test "update_reservation/2 with invalid data returns error changeset", %{
      invalid_attrs: invalid_attrs
    } do
      reservation = reservation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Reservations.update_reservation(reservation, invalid_attrs)

      assert reservation == Reservations.get_reservation!(reservation.id)
    end

    test "delete_reservation/1 deletes the reservation" do
      reservation = reservation_fixture()
      assert {:ok, %Reservation{}} = Reservations.delete_reservation(reservation)
      assert_raise Ecto.NoResultsError, fn -> Reservations.get_reservation!(reservation.id) end
    end

    test "change_reservation/1 returns a reservation changeset" do
      reservation = reservation_fixture()
      assert %Ecto.Changeset{} = Reservations.change_reservation(reservation)
    end
  end
end
