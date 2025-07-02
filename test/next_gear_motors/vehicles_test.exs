defmodule NextGearMotors.VehiclesTest do
  use NextGearMotors.DataCase

  alias NextGearMotors.Vehicles
  alias NextGearMotors.Vehicles.Covers.Cover

  setup do
    File.mkdir_p("priv/static/test/uploads")
    File.mkdir_p("priv/static/test/tmp")
    System.put_env("TMPDIR", "priv/static/tmp")

    on_exit(fn ->
      File.rm_rf("priv/static/test/uploads")
      File.rm_rf("priv/static/test/tmp")
    end)
  end

  describe "vehicles" do
    alias NextGearMotors.Vehicles.Vehicle

    import NextGearMotors.VehiclesFixtures

    @invalid_attrs %{name: nil, description: nil, price: nil, manufacturer: nil}

    test "list_vehicles/0 returns all vehicles" do
      vehicle = vehicle_fixture()
      assert Vehicles.list_vehicles() == [vehicle]
    end

    test "get_vehicle!/1 returns the vehicle with given id" do
      vehicle = vehicle_fixture()
      assert Vehicles.get_vehicle!(vehicle.id) == vehicle
    end

    test "create_vehicle/1 with valid data creates a vehicle" do
      cover = %Plug.Upload{
        path: "test/support/fixtures/vehicles_fixtures/car.jpg",
        filename: "car.jpg",
        content_type: "image/jpeg"
      }

      valid_attrs = %{
        name: "some name",
        description: "some description",
        price: "some price",
        manufacturer: "some manufacturer",
        cover: cover
      }

      assert {:ok, %Vehicle{} = vehicle} = Vehicles.create_vehicle(valid_attrs)
      assert vehicle.name == "some name"
      assert vehicle.description == "some description"
      assert vehicle.price == "some price"
      assert vehicle.manufacturer == "some manufacturer"
      assert vehicle.cover.file_name == "car.jpg"
    end

    test "create_vehicle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Vehicles.create_vehicle(@invalid_attrs)
    end

    test "update_vehicle/2 with valid data updates the vehicle" do
      vehicle = vehicle_fixture()
      prev_cover = vehicle.cover

      updated_cover = %Plug.Upload{
        path: "test/support/fixtures/vehicles_fixtures/updated_car.jpg",
        filename: "updated_car.jpg",
        content_type: "image/jpeg"
      }

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        price: "some updated price",
        manufacturer: "some updated manufacturer",
        cover: updated_cover
      }

      assert {:ok, %Vehicle{} = vehicle} = Vehicles.update_vehicle(vehicle, update_attrs)
      assert vehicle.name == "some updated name"
      assert vehicle.description == "some updated description"
      assert vehicle.price == "some updated price"
      assert vehicle.manufacturer == "some updated manufacturer"
      assert vehicle.cover.file_name == "updated_car.jpg"

      refute File.exists?("priv/static" <> Cover.url(prev_cover))
    end

    test "update_vehicle/2 with invalid data returns error changeset" do
      vehicle = vehicle_fixture()
      assert {:error, %Ecto.Changeset{}} = Vehicles.update_vehicle(vehicle, @invalid_attrs)
      assert vehicle == Vehicles.get_vehicle!(vehicle.id)
    end

    test "delete_vehicle/1 deletes the vehicle" do
      vehicle = vehicle_fixture()
      prev_cover = vehicle.cover

      assert {:ok, %Vehicle{}} = Vehicles.delete_vehicle(vehicle)
      assert_raise Ecto.NoResultsError, fn -> Vehicles.get_vehicle!(vehicle.id) end

      refute File.exists?("priv/static" <> Cover.url(prev_cover))
    end

    test "change_vehicle/1 returns a vehicle changeset" do
      vehicle = vehicle_fixture()
      assert %Ecto.Changeset{} = Vehicles.change_vehicle(vehicle)
    end
  end
end
