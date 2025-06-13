defmodule NewGearMotors.MixProject do
  use Mix.Project

  def project do
    [
      app: :new_gear_motors,
      version: "0.5.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: &docs/0
    ]
  end

  # ExDoc Configuration
  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE.txt"]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {NewGearMotors.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:argon2_elixir, "~> 4.0"},
      {:bandit, "~> 1.5"},
      {:bun, "~> 1.4", runtime: Mix.env() == :dev},
      {:credo, "~> 1.7", runtime: false},
      {:deps_nix, "~> 2.0", only: :dev},
      {:dns_cluster, "~> 0.1.1"},
      {:ecto_sql, "~> 3.10"},
      {:ex_doc, "~> 0.38", runtime: false, warn_if_outdated: true},
      {:finch, "~> 0.13"},
      {:floki, ">= 0.30.0"},
      {:gettext, "~> 0.20"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:jason, "~> 1.2"},
      {:mix_audit, "~> 2.1", runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mogrify, "~> 0.9.3"},
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.5"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.11", override: true},
      {:postgrex, ">= 0.0.0"},
      {:sobelow, "~> 0.13", runtime: false},
      {:swoosh, "~> 1.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:waffle, "~> 1.1"},
      {:waffle_ecto, "~> 0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "deps.get": [
        "deps.get",
        "deps.nix"
      ],
      "deps.update": ["deps.update", "deps.nix"],
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": [
        "bun.install --if-missing",
        "bun assets install"
      ],
      "assets.build": ["bun new_gear_motors", "bun css"],
      "assets.deploy": [
        "bun css --minify",
        "bun new_gear_motors --minify",
        "phx.digest"
      ]
    ]
  end
end
