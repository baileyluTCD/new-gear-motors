defmodule NewGearMotors.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :string
      add :reservation_id, references(:reservations, on_delete: :delete_all, type: :binary_id)
      add :from_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:reservation_id])
    create index(:messages, [:from_id])
  end
end
