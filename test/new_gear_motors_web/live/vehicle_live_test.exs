defmodule NewGearMotorsWeb.VehicleLiveTest do
  use NewGearMotorsWeb.ConnCase

  import Phoenix.LiveViewTest
  import NewGearMotors.VehiclesFixtures

  @create_attrs %{
    name: "some name",
    description: "some description",
    price: "some price",
    manufacturer: "some manufacturer"
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    price: "some updated price",
    manufacturer: "some updated manufacturer"
  }
  @invalid_attrs %{name: nil, description: nil, price: nil, manufacturer: nil}

  defp create_vehicle(_) do
    vehicle = vehicle_fixture()
    %{vehicle: vehicle}
  end

  describe "Logged Out Index" do
    setup [:create_vehicle]

    test "lists all vehicles", %{conn: conn, vehicle: vehicle} do
      {:ok, _index_live, html} = live(conn, ~p"/vehicles")

      assert html =~ "Vehicles"
      assert html =~ vehicle.name
    end

    test "has no new button", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      refute has_element?(index_live, "a", "New Vehicle")
    end

    test "has no edit button", %{conn: conn, vehicle: vehicle} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      refute has_element?(index_live, "#vehicles-#{vehicle.id} a", "Edit")
    end

    test "has no delete button", %{conn: conn, vehicle: vehicle} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      refute has_element?(index_live, "#vehicles-#{vehicle.id} a", "Delete")
    end
  end

  describe "Logged in Index" do
    setup [:create_vehicle, :register_and_log_in_user]

    test "saves new vehicle", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      assert index_live
             |> element("a", "New Vehicle")
             |> render_click() =~ "New Vehicle"

      assert index_live
             |> form("#vehicle-form", vehicle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#vehicle-form", vehicle: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/vehicles")

      html = render(index_live)
      assert html =~ "Vehicle created successfully"
      assert html =~ "some name"
    end

    test "updates vehicle in listing", %{conn: conn, vehicle: vehicle} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      assert index_live
             |> element("#vehicles-#{vehicle.id} a", "Edit")
             |> render_click() =~ "Edit"

      assert_patch(index_live, ~p"/vehicles/#{vehicle}/edit")

      assert index_live
             |> form("#vehicle-form", vehicle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#vehicle-form", vehicle: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/vehicles")

      html = render(index_live)
      assert html =~ "Vehicle updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes vehicle in listing", %{conn: conn, vehicle: vehicle} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      assert index_live |> element("#vehicles-#{vehicle.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#vehicles-#{vehicle.id}")
    end
  end

  describe "Logged in Show" do
    setup [:create_vehicle, :register_and_log_in_user]

    test "updates vehicle within modal", %{conn: conn, vehicle: vehicle} do
      {:ok, show_live, _html} = live(conn, ~p"/vehicles/#{vehicle}")

      assert show_live |> element("a", "Edit Vehicle") |> render_click() =~
               "Edit Vehicle"

      assert_patch(show_live, ~p"/vehicles/#{vehicle}/show/edit")

      assert show_live
             |> form("#vehicle-form", vehicle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#vehicle-form", vehicle: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/vehicles/#{vehicle}")

      html = render(show_live)
      assert html =~ "Vehicle updated successfully"
      assert html =~ "some updated name"
    end
  end

  describe "Logged out Show" do
    setup [:create_vehicle]

    test "displays vehicle", %{conn: conn, vehicle: vehicle} do
      {:ok, _show_live, html} = live(conn, ~p"/vehicles/#{vehicle}")

      assert html =~ "Show Vehicle"
      assert html =~ vehicle.name
    end
  end
end
