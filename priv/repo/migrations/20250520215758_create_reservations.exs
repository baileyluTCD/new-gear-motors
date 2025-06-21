defmodule NewGearMotors.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    create table(:reservations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :planned_meeting_time, :naive_datetime
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :vehicle_id, references(:vehicles, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:reservations, [:user_id])
    create index(:reservations, [:vehicle_id])
  end
end
