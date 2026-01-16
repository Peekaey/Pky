defmodule PkyWeb.IndexLive do
  @moduledoc """
  LiveView for the index/home page.
  """
  # TODO - Fix up div Ids
alias PkyWeb.Live.Components.Slices.TechnologiesSlice
  use PkyWeb, :live_view

  use Phoenix.VerifiedRoutes,
    endpoint: PkyWeb.Endpoint,
    router: PkyWeb.Router,
    statics: PkyWeb.static_paths()

  # Aliases for Service and Model
  alias Pky.BusinessService.MioriBusinessService
  alias Pky.Models.MioriUserData

  # Component Aliases
  alias PkyWeb.Live.Components.LoadingComponent
  alias PkyWeb.Live.Components.CarouselComponent
  alias PkyWeb.Live.Components.Widgets.UptimeWidget
  alias PkyWeb.Live.Components.Widgets.AnilistWidget
  alias PkyWeb.Live.Components.Widgets.WeatherWidget
  alias PkyWeb.Live.Components.LinksSlice
  import PkyWeb.Live.Components.SvgComponents

  # GenServers for live updating of components
  alias Pky.GenServers.UptimeMonitor
  alias Pky.GenServers.WeatherMonitor
  require Logger

  # Ensure you created this helper from the previous step
  alias PkyWeb.Live.CursorTracking.CursorUtils

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to PubSub if the socket is connected
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Pky.PubSub, "uptime_results")
      Phoenix.PubSub.subscribe(Pky.PubSub, "weather_result")

      Phoenix.PubSub.subscribe(Pky.PubSub, "cursor_tracking")

      :timer.send_interval(1000, self(), :clean_inactive_cursors)

      send(self(), :fetch_user_data)
    end

    user_id = Ecto.UUID.generate()
    color = CursorUtils.random_color()
    name = CursorUtils.random_name()

    initial_uptime_results = Pky.GenServers.UptimeMonitor.get_latest()
    initial_weather_result = Pky.GenServers.WeatherMonitor.get_latest()

    socket =
      socket
      |> assign(:page_title, "Home")
      |> assign(:user_data, nil)
      |> assign(:uptime_results, initial_uptime_results)
      |> assign(:weather_result, initial_weather_result)
      |> assign(:loading, true)
      |> assign(:user_id, user_id)
      |> assign(:user_color, color)
      |> assign(:user_name, name)
      |> assign(:cursors, %{})
      |> assign(:clicks, [])

    {:ok, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    if socket.assigns[:user_id] do
      Phoenix.PubSub.broadcast(
        Pky.PubSub,
        "cursor_tracking",
        {:remove_cursor, socket.assigns.user_id}
      )
    end

    :ok
  end

  # Handles cursor updates from other users
  @impl true
  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    payload = %{
      id: socket.assigns.user_id,
      x: x,
      y: y,
      color: socket.assigns.user_color,
      name: socket.assigns.user_name
    }

    # Broadcast to others, but NOT to self
    Phoenix.PubSub.broadcast_from!(
      Pky.PubSub,
      self(),
      "cursor_tracking",
      {:cursor_update, payload}
    )

    {:noreply, socket}
  end

  # Runs when current user clicks
  # Generates unique click id (to prevent duplicate clicks) and sends to server
  @impl true
  def handle_event("cursor-click", %{"x" => x, "y" => y}, socket) do
    click_id = Ecto.UUID.generate()

    payload = %{
      id: click_id,
      user_id: socket.assigns.user_id,
      x: x,
      y: y,
      color: socket.assigns.user_color
    }

    Phoenix.PubSub.broadcast_from!(
      Pky.PubSub,
      self(),
      "cursor_tracking",
      {:cursor_click, payload}
    )

    {:noreply, socket}
  end

  # Handles messages of clicks from other users
  @impl true
  def handle_info({:cursor_click, payload}, socket) do
    Process.send_after(self(), {:remove_click, payload.id}, 1000)
    {:noreply, assign(socket, :clicks, [payload | socket.assigns.clicks])}
  end

  # Handles removing the click animation
  @impl true
  def handle_info({:remove_click, id}, socket) do
    clicks = Enum.reject(socket.assigns.clicks, fn c -> c.id == id end)
    {:noreply, assign(socket, :clicks, clicks)}
  end

  # Handles other user cursor updates
  @impl true
  def handle_info({:cursor_update, payload}, socket) do
    payload_with_time = Map.put(payload, :last_seen, System.system_time(:millisecond))

    updated_cursors = Map.put(socket.assigns.cursors, payload.id, payload_with_time)
    {:noreply, assign(socket, :cursors, updated_cursors)}
  end

  # Updates the uptime results for sites monitored
  @impl true
  def handle_info({:new_uptime_data, results}, socket) do
    {:noreply, assign(socket, :uptime_results, results)}
  end

  # Handles getting site data
  @impl true
  def handle_info(:fetch_user_data, socket) do
    case MioriBusinessService.get_miori_user_data() do
      {:ok, %MioriUserData{} = user_data} ->
        {:noreply, assign(socket, user_data: user_data, loading: false)}

      {:error, reason} ->
        Logger.error("Failed to fetch user data: #{inspect(reason)}")

        {:noreply,
         assign(socket, user_data: nil, loading: false)
         |> put_flash(:error, "Could not load user data.")}
    end
  end

  # Periodic scanner to check for stale cursors and remove them
  @impl true
  def handle_info(:clean_inactive_cursors, socket) do
    now = System.system_time(:millisecond)
    # Time in ms before we consider a user disconnected
    timeout = 10_000

    active_cursors =
      Map.filter(socket.assigns.cursors, fn {_id, user} ->
        # Keep user only if they were seen recently
        last_seen = Map.get(user, :last_seen)

        last_seen && now - last_seen < timeout
      end)

    {:noreply, assign(socket, :cursors, active_cursors)}
  end

  # Graceful removal of a users cursor
  @impl true
  def handle_info({:remove_cursor, leaving_user_id}, socket) do
    # Remove the cursor from the map
    new_cursors = Map.delete(socket.assigns.cursors, leaving_user_id)

    {:noreply, assign(socket, :cursors, new_cursors)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <LoadingComponent.loading_screen />
    <% else %>
      <div
        id="cursor-tracker"
        phx-hook="CursorTracking"
        class="bg-cover bg-center bg-no-repeat min-h-screen text-white p-6 relative overflow-hidden"
        style={"background-image: url('#{~p"/images/gifs/city-pixel-noon.gif"}')"}
      >
        <%= if @user_data do %>
          <div id="index-content">
            <div id="index-centre-container" class="justify-center flex">
              <div class="border-gray-500 border-4 p-6 rounded-xl max-w-5xl w-full bg-gray-900/50 backdrop-blur-xl">
                <div id="index-inside-centre-container">
                  <div
                    id="index-centre-container-header"
                    class="flex flex-row items-start justify-between w-full"
                  >
                    <div class="shrink-0">
                      <%= if @user_data.discord do %>
                        <img
                          src={~p"/images/icon.jpg"}
                          alt="Discord Avatar"
                          class="rounded-xl w-34 h-34 object-cover shadow-lg border-2 border-gray-600"
                        />
                      <% else %>
                        <img
                          src={~p"/images/icon.jpg"}
                          alt="Default Avatar"
                          class="rounded-xl w-40 h-40 object-cover shadow-lg border-2 border-gray-600"
                        />
                      <% end %>
                    </div>

                    <div class="flex flex-col items-end text-right max-w-xl ml-6">
                      <%= if @user_data.discord do %>
                        <h2 class="text-3xl font-bold mb-3 text-white font-">
                          {@user_data.discord.global_username}
                        </h2>
                      <% else %>
                        <h2 class="text-3xl font-bold mb-3 text-white">peekaey</h2>
                      <% end %>

                      <p class="text-lg text-gray-200 leading-relaxed">
                        Occasional doer of things
                      </p>

                      <.live_component
                        module={WeatherWidget}
                        id="weather-widget"
                        weather_result={@weather_result}
                      />
                      <% # Local DateTime Widget from JS hook %>
                      <div class="flex flex-col gap-2 text-gray-400 font-mono text-sm ">
                        <span id="local-time" phx-update="ignore" phx-hook="LocalTime">
                          Loading...
                        </span>
                      </div>
                    </div>
                  </div>

                  <div id="index-centre-container-carousel" class="mt-6">
                    <.live_component
                      module={CarouselComponent}
                      id="user-carousel"
                      user_data={@user_data}
                    />
                  </div>

                  <div
                    id="index-centre-container-service-status"
                    class="mt-6 flex flex-col items-center"
                  >
                    <h3 class="text-xl font-bold mb-4">Service Status</h3>

                    <.live_component
                      module={UptimeWidget}
                      id="uptime-slice"
                      results={@uptime_results}
                    />
                  </div>

                  <div
                    id="index-centre-container-technologies" class="mt-6 flex flex-col items-center">
                    <h3 class="text-xl font-bold mb-4">Technologies</h3>
                    <div class="grid grid-cols-1  gap-4">
                    <.live_component
                    module={TechnologiesSlice}
                    id="technologies"
                    />
                    </div>
                  </div>

                  <div
                    id="index-centre-container-footer"
                    class="mt-6 text-gray-300 justify-center flex flex-col items-center"
                  >
                    <h3 class="text-xl font-bold">Links</h3>
                    <div id="index-centre-container-footer-links" class="mt-5 mb-5">
                      <.live_component
                      module={LinksSlice}
                      id="social-links"
                      />

                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        <% else %>
          <div class="flex flex-col items-center justify-center h-screen relative z-10">
            <p class="text-xl font-bold">User data could not be loaded.</p>
            <p class="text-sm text-gray-300 mt-2">Please try refreshing the page.</p>
          </div>
        <% end %>

        <div class="absolute inset-0 pointer-events-none z-50">
          <div
            :for={click <- @clicks}
            id={"click-#{click.id}"}
            class="absolute w-6 h-6 rounded-full animate-ping opacity-75"
            style={"left: #{click.x}%; top: #{click.y}%; background-color: #{click.color}; transform: translate(-50%, -50%); animation-iteration-count: 1;"}
          >
          </div>

          <div
            :for={{user_id, cursor} <- @cursors}
            :if={user_id != @user_id}
            class="absolute transition-all duration-75 ease-linear will-change-transform"
            style={"left: #{cursor.x}%; top: #{cursor.y}%;"}
          >
            <svg
              class="drop-shadow-md"
              width="24"
              height="24"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M5.65376 12.3673H5.46026L5.31717 12.4976L0.500002 16.8829L0.500002 1.19841L11.7841 12.3673H5.65376Z"
                fill={cursor.color}
                stroke="white"
                stroke-width="1"
              />
            </svg>

            <span
              class="absolute left-4 top-4 px-2 py-1 text-xs font-bold text-white rounded-md shadow-md whitespace-nowrap opacity-90"
              style={"background-color: #{cursor.color};"}
            >
              {cursor.name}
            </span>
          </div>
        </div>
      </div>
    <% end %>
    """
  end
end
