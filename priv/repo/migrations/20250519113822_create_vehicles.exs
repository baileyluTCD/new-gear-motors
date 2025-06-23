defmodule NextGearMotors.Repo.Migrations.CreateVehicles do
  use Ecto.Migration

  def change do
    create table(:vehicles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :price, :string
      add :description, :text
      add :manufacturer, :string
      add :cover, :map

      timestamps(type: :utc_datetime)
    end
  end
end
