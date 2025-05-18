defmodule NewGearMotors.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NewGearMotorsWeb.Telemetry,
      NewGearMotors.Repo,
      {DNSCluster, query: Application.get_env(:new_gear_motors, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NewGearMotors.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: NewGearMotors.Finch},
      # Start a worker by calling: NewGearMotors.Worker.start_link(arg)
      # {NewGearMotors.Worker, arg},
      # Start to serve requests, typically the last entry
      NewGearMotorsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NewGearMotors.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NewGearMotorsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
