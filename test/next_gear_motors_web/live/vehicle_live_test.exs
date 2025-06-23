defmodule NextGearMotorsWeb.VehicleLiveTest do
  use NextGearMotorsWeb.ConnCase

  import Phoenix.LiveViewTest
  import NextGearMotors.VehiclesFixtures

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

  @cover %{
    name: "car.jpg",
    content: File.read!("test/support/fixtures/vehicles_fixtures/car.jpg"),
    type: "image/jpeg"
  }
  @updated_cover %{
    name: "updated_car.jpg",
    content: File.read!("test/support/fixtures/vehicles_fixtures/updated_car.jpg"),
    type: "image/jpeg"
  }

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

      refute has_element?(index_live, "#vehicles-#{vehicle.id}-edit a")
    end

    test "has no delete button", %{conn: conn, vehicle: vehicle} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      refute has_element?(index_live, "#vehicles-#{vehicle.id}-delete a")
    end
  end

  describe "Logged in Index" do
    setup [:create_vehicle, :register_and_log_in_user]

    test "has no edit button", %{conn: conn, vehicle: vehicle} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      refute has_element?(index_live, "#vehicles-#{vehicle.id}-edit a")
    end

    test "has no delete button", %{conn: conn, vehicle: vehicle} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      refute has_element?(index_live, "#vehicles-#{vehicle.id}-delete a")
    end
  end

  describe "Admin Logged in Index" do
    setup [:create_vehicle, :register_log_in_and_promote_user]

    test "saves new vehicle", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      assert index_live
             |> element("a", "New Vehicle")
             |> render_click() =~ "New Vehicle"

      assert index_live
             |> form("#vehicle-form", vehicle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> file_input("#vehicle-form", :cover, [@cover])
             |> render_upload("car.jpg") =~ "img src=\"/images/car"

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
             |> element("a#vehicles-#{vehicle.id}-edit")
             |> render_click() =~ "Edit Vehicle"

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

      assert index_live |> element("a#vehicles-#{vehicle.id}-delete") |> render_click()
      refute has_element?(index_live, "#vehicles-#{vehicle.id}")
    end
  end

  describe "Logged in Show" do
    setup [:create_vehicle, :register_and_log_in_user]

    test "has no edit button", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/vehicles")

      refute has_element?(index_live, "a", "Edit")
    end
  end

  describe "Admin Logged in Show" do
    setup [:create_vehicle, :register_log_in_and_promote_user]

    test "updates vehicle within modal", %{conn: conn, vehicle: vehicle} do
      {:ok, show_live, _html} = live(conn, ~p"/vehicles/#{vehicle}")

      assert show_live
             |> element("a", "Edit")
             |> render_click() =~ "Edit Vehicle"

      assert_patch(show_live, ~p"/vehicles/#{vehicle}/show/edit")

      assert show_live
             |> form("#vehicle-form", vehicle: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> file_input("#vehicle-form", :cover, [@updated_cover])
             |> render_upload("updated_car.jpg") =~ "img src=\"/images/car"

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
