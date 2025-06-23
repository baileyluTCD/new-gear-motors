defmodule NextGearMotors.Repo do
  use Ecto.Repo,
    otp_app: :next_gear_motors,
    adapter: Ecto.Adapters.Postgres
end
