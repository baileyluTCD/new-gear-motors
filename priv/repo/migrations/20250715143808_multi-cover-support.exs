defmodule :"Elixir.NextGearMotors.Repo.Migrations.Multi-cover-support" do
  use Ecto.Migration

  def change do
    alter table(:vehicles) do
      remove :cover
      add :covers, {:array, :map}, default: []
    end
  end
end
