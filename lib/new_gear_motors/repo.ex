defmodule NewGearMotors.Repo do
  use Ecto.Repo,
    otp_app: :new_gear_motors,
    adapter: Ecto.Adapters.Postgres
end
