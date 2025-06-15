# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :new_gear_motors,
  ecto_repos: [NewGearMotors.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :new_gear_motors, NewGearMotorsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: NewGearMotorsWeb.ErrorHTML, json: NewGearMotorsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: NewGearMotors.PubSub,
  live_view: [signing_salt: "3yrfm40n"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :new_gear_motors, NewGearMotors.Mailer, adapter: Swoosh.Adapters.Local

config :bun,
  version: "1.2.14",
  assets: [args: [], cd: Path.expand("../assets", __DIR__)],
  new_gear_motors: [
    args: ~w(build js/app.js --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__)
  ],
  css: [
    args: ~w(run tailwindcss --input=css/app.css --output=../priv/static/assets/app.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir_prefix: "priv/static",
  storage_dir: "images"

# Clear the console for each run of mix test.watch
config :mix_test_watch,
  clear: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
