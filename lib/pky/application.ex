defmodule Pky.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PkyWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:pky, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pky.PubSub},
      # Start a worker by calling: Pky.Worker.start_link(arg)
      # {Pky.Worker, arg},
      # Start to serve requests, typically the last entry
      PkyWeb.Endpoint,
      Pky.GenServers.UptimeMonitor,
      Pky.GenServers.WeatherMonitor

    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pky.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PkyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
