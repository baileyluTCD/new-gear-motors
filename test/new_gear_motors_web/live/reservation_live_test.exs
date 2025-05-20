defmodule NewGearMotorsWeb.ReservationLiveTest do
  use NewGearMotorsWeb.ConnCase

  import Phoenix.LiveViewTest
  import NewGearMotors.ReservationsFixtures

  @create_attrs %{status: :denied, planned_meeting_time: "2025-05-19T21:58:00"}
  @update_attrs %{status: :pending, planned_meeting_time: "2025-05-20T21:58:00"}
  @invalid_attrs %{status: nil, planned_meeting_time: nil}

  defp create_reservation(_) do
    reservation = reservation_fixture()
    %{reservation: reservation}
  end

  describe "Index" do
    setup [:create_reservation]

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

      assert index_live |> element("#reservations-#{reservation.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#reservations-#{reservation.id}")
    end
  end

  describe "Show" do
    setup [:create_reservation]

    test "displays reservation", %{conn: conn, reservation: reservation} do
      {:ok, _show_live, html} = live(conn, ~p"/reservations/#{reservation}")

      assert html =~ "Show Reservation"
    end

    test "updates reservation within modal", %{conn: conn, reservation: reservation} do
      {:ok, show_live, _html} = live(conn, ~p"/reservations/#{reservation}")

      assert show_live |> element("a", "Edit") |> render_click() =~
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
end
