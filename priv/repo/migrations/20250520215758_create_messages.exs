defmodule NewGearMotors.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :from, references(:users, on_delete: :nothing, type: :binary_id)
      add :to, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:from])
    create index(:messages, [:to])
  end
end
