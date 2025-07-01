defmodule NextGearMotors.Vehicles.CoversTest do
  use NextGearMotors.DataCase

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

  describe "covers" do
    @img "test/support/fixtures/vehicles_fixtures/car.jpg"

    test "store creates an image" do
      {:ok, "car.jpg"} = Cover.store(@img)
    end
  end
end
