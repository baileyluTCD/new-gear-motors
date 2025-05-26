defmodule NewGearMotorsWeb.ReservationLiveTest do
  use NewGearMotorsWeb.ConnCase

  import Phoenix.LiveViewTest
  import NewGearMotors.ReservationsFixtures
  import NewGearMotors.Reservations.MessagesFixtures
  import NewGearMotors.AccountsFixtures

  @create_attrs %{status: :denied, planned_meeting_time: "2025-05-19T21:58:00"}
  @update_attrs %{status: :pending, planned_meeting_time: "2025-05-20T21:58:00"}
  @invalid_attrs %{status: nil, planned_meeting_time: nil}

  @create_message_attrs %{text: "some text"}
  @update_message_attrs %{text: "updated text"}
  @invalid_message_attrs %{text: nil}

  defp create_reservation(_) do
    reservation = reservation_fixture()
    user = user_fixture()

    message = message_fixture(%{user: user, reservation: reservation})

    %{
      user: user,
      reservation: reservation,
      message: message
    }
  end

  describe "Index" do
    setup [:create_reservation, :register_and_log_in_user]

    test "lists all reservations", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/reservations")

      assert html =~ "Listing Reservations"
    end

    test "saves new reservation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/reservations")

      assert index_live |> element("a", "New Reservation") |> render_click() =~
               "New Reservation"

      assert_patch(index_live, ~p"/reservations/new")

      assert index_live
             |> form("#reservation-form", reservation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#reservation-form", reservation: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/reservations")

      html = render(index_live)
      assert html =~ "Reservation created successfully"
    end

    test "updates reservation in listing", %{conn: conn, reservation: reservation} do
      {:ok, index_live, _html} = live(conn, ~p"/reservations")

      assert index_live |> element("#reservations-#{reservation.id} a", "Edit") |> render_click() =~
               "Edit Reservation"

      assert_patch(index_live, ~p"/reservations/#{reservation}/edit")

      assert index_live
             |> form("#reservation-form", reservation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#reservation-form", reservation: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/reservations")

      html = render(index_live)
      assert html =~ "Reservation updated successfully"
    end

    test "deletes reservation in listing", %{conn: conn, reservation: reservation} do
      {:ok, index_live, _html} = live(conn, ~p"/reservations")

      assert index_live
             |> element("#reservations-#{reservation.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#reservations-#{reservation.id}")
    end
  end

  describe "Show" do
    setup [:create_reservation, :register_and_log_in_user]

    test "displays reservation", %{conn: conn, reservation: reservation} do
      {:ok, _show_live, html} = live(conn, ~p"/reservations/#{reservation}")

      assert html =~ "Show Reservation"
    end

    test "updates reservation within modal", %{conn: conn, reservation: reservation} do
      {:ok, show_live, _html} = live(conn, ~p"/reservations/#{reservation}")

      assert show_live |> element("a", "Edit Reservation") |> render_click() =~
               "Edit Reservation"

      assert_patch(show_live, ~p"/reservations/#{reservation}/show/edit")

      assert show_live
             |> form("#reservation-form", reservation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#reservation-form", reservation: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/reservations/#{reservation}")

      html = render(show_live)
      assert html =~ "Reservation updated successfully"
    end
  end

  describe "Messages" do
    setup [:create_reservation, :register_and_log_in_user]

    test "displays messages", %{conn: conn, reservation: reservation} do
      {:ok, _show_live, html} = live(conn, ~p"/reservations/#{reservation}")

      assert html =~ "Messages"
    end

    test "saves new message", %{conn: conn, reservation: reservation} do
      {:ok, show_live, _html} = live(conn, ~p"/reservations/#{reservation}")

      assert show_live
             |> form("#messages-form", message: @invalid_message_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#messages-form", message: @create_message_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/reservations/#{reservation}")

      html = render(show_live)
      assert html =~ "Message sent successfully"
    end

    test "updates message within modal", %{conn: conn, reservation: reservation, message: message} do
      {:ok, show_live, _html} = live(conn, ~p"/reservations/#{reservation}")

      assert show_live
             |> element("#messages-#{message.id} a", "Edit")
             |> render_click() =~
               "Edit Message"

      assert_patch(show_live, ~p"/reservations/#{reservation}/messages/#{message}/edit")

      assert show_live
             |> form("#messages-edit-form", message: @invalid_message_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#messages-edit-form", message: @update_message_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/reservations/#{reservation}")

      html = render(show_live)
      assert html =~ "Message updated successfully"
    end

    test "deletes message in listing", %{conn: conn, reservation: reservation, message: message} do
      {:ok, show_live, _html} = live(conn, ~p"/reservations/#{reservation}")

      assert show_live
             |> element("#messages-#{message.id} a", "Delete")
             |> render_click()

      refute has_element?(show_live, "#message-#{message.id}")
    end
  end
end
