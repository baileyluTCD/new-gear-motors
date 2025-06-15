defmodule NewGearMotors.Vehicles.CoversTest do
  use NewGearMotors.DataCase

  alias NewGearMotors.Vehicles
  alias NewGearMotors.Vehicles.Covers.Cover
  alias NewGearMotors.Vehicles.Covers

  setup do
    File.mkdir_p("priv/static/images")
    File.mkdir_p("priv/static/tmp")
    System.put_env("TMPDIR", "priv/static/tmp")

    on_exit(fn ->
      File.rm_rf("priv/static/images")
      File.rm_rf("priv/static/tmp")
    end)
  end

  describe "covers" do
    @img "test/support/fixtures/vehicles_fixtures/car.jpg"

    test "store creates an image" do
      {:ok, "car.jpg"} = Cover.store(@img)
    end
  end
end
