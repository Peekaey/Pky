defmodule Pky.GenServers.UptimeMonitor do
  @moduledoc """
  Periodically checks the status of configured websites and broadcasts updates to their availability
  """
  use GenServer
  require Logger

  alias Pky.BusinessService.UptimeMonitorBusinessService
  alias Pky.Models.MonitoredSite

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Manual call to get the latest data outside of a broadcast (such as during a page refresh)
  def get_latest do
    GenServer.call(__MODULE__, :get_results)
  end

  @impl true
  def init(state) do
    # Start the first check immediately
    send(self(), :check_uptime)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_results, _from, state) do
    # Return the last known results
    {:reply, Map.get(state, :results, []), state}
  end

  @impl true
  def handle_info(:check_uptime, state) do
    sites = monitored_sites()

    results =
      Enum.map(sites, fn site ->
        UptimeMonitorBusinessService.check_site(site)
      end)

    Logger.info("Uptime check completed for #{length(results)} sites.")

    # Broadcast results (List of {MonitoredSite, :up/:down})
    Phoenix.PubSub.broadcast(Pky.PubSub, "uptime_results", {:new_uptime_data, results})

    # Schedule next check in 60 seconds
    Process.send_after(self(), :check_uptime, 60_000)

    {:noreply, Map.put(state, :results, results)}
  end

  defp monitored_sites do
    [
      MonitoredSite.new("https://plex.refrain.app", "plex @ miyuki"),
      MonitoredSite.new("https://forgejo.refrain.app", "forgejo @ miyuki"),
      MonitoredSite.new("https://api.miori.dev", "api @ miori")
    ]
  end
end
