import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :argon2_elixir, t_cost: 1, m_cost: 8

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :next_gear_motors, NextGearMotors.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "next_gear_motors_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :next_gear_motors, NextGearMotorsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "BoWWocZ2oy4Wdahhy1HWeaoy6tr7YWcB0O1xm5mxSZ6YSP4vRfaGXfFp4knzi4WT",
  server: false

# In test we don't send emails
config :next_gear_motors, NextGearMotors.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "priv/static",
  storage_dir: "uploads"
