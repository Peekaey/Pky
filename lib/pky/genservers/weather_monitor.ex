defmodule Pky.GenServers.WeatherMonitor do
  @moduledoc """
  Periodically gets the weather status from OpenWeather API and brodcasts updates to their availability
  """
  use GenServer
  alias Pky.BusinessService.WeatherBusinessService
  require Logger

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
    send(self(), :check_weather)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_results, _from, state) do
    # Return the last known results
    {:reply, Map.get(state, :results, []), state}
  end

  @impl true
  def handle_info(:check_weather, state) do

    results = WeatherBusinessService.fetch_sydney_weather()

    # Broadcast results (WeatherData)
    Logger.info("Weather Results: #{inspect(results)}")

    Phoenix.PubSub.broadcast(Pky.PubSub, "weather_results", {:new_weather_data, results})
    # Schedule next check in 10 minutes
    Process.send_after(self(), :check_weather, 600_000)
    {:noreply, Map.put(state, :results, results)}
  end
end
