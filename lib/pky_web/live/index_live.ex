defmodule PkyWeb.IndexLive do
  @moduledoc """
  LiveView for the index/home page.
  """
  # TODO - Fix up div Ids
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
  alias PkyWeb.Live.Components.UptimeWidget
  alias PkyWeb.Live.Components.AnilistWidget
  alias PkyWeb.Live.Components.WeatherWidget
  import PkyWeb.Live.Components.SvgComponents

  # GenServers for live updating of components
  alias Pky.GenServers.UptimeMonitor
  alias Pky.GenServers.WeatherMonitor
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # Subscribe to PubSub if the socket is connected
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Pky.PubSub, "uptime_results")
      Phoenix.PubSub.subscribe(Pky.PubSub, "weather_result")
      send(self(), :fetch_user_data)
    end

    initial_uptime_results = Pky.GenServers.UptimeMonitor.get_latest()
    initial_weather_result = Pky.GenServers.WeatherMonitor.get_latest()

    socket =
      socket
      |> assign(:page_title, "Home")
      |> assign(:user_data, nil)
      |> assign(:uptime_results, initial_uptime_results)
      |> assign(:weather_result, initial_weather_result)
      |> assign(:loading, true)

    {:ok, socket}
  end

  @impl true
  def handle_info({:new_uptime_data, results}, socket) do
    {:noreply, assign(socket, :uptime_results, results)}
  end

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

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @loading do %>
      <LoadingComponent.loading_screen />
    <% else %>
      <div
        class="bg-cover bg-center bg-no-repeat min-h-screen text-white p-6"
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
                    <div class="flex-shrink-0">
                      <%= if @user_data.discord do %>
                        <img
                          src={~p"/images/icon.jpg"}
                          alt="Discord Avatar"
                          class="rounded-xl w-34 h-34 object-cover shadow-lg border-2 border-gray-600"
                        />
                        <%!-- <h2 class="text-3xl font-bold mb-3 text-white"><%= @user_data.discord.global_username %></h2> --%>
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

                  <%!-- <div class ="mt-6 flex flex-col items-center">
                                      <h3 class="text-xl font-bold mb-4">Anilist</h3>

                    <div class="items-center flex flex-col">
                      <.live_component
                        module={AnilistWidget}
                        id="anilist-slice"
                        user_data={@user_data}
                      />
                    </div>
                  </div> --%>

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
                    id="index-centre-container-technologies"
                    class="mt-6 flex flex-col items-center"
                  >
                    <h3 class="text-xl font-bold mb-4">Technologies</h3>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4"></div>
                  </div>

                  <div
                    id="index-centre-container-footer"
                    class="mt-6 text-gray-300 justify-center flex flex-col items-center"
                  >
                    <h3 class="text-xl font-bold">Links</h3>
                    <div id="index-centre-container-footer-links" class="mt-5 mb-5">
                      <%= if @user_data.discord do %>
                        <a
                          id="discord-link"
                          href={"https://discord.com/users/#{@user_data.discord.uuid}"}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <.discord_logo class="inline h-8 mr-2 text-white" />
                        </a>
                      <% end %>

                      <a
                        id="github-link"
                        href="https://github.com/Peekaey"
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <.github_logo class="inline h-10 mr-2 text-white" />
                      </a>

                      <a
                        id="statsfm-link"
                        href="https://stats.fm/peekaey"
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <.statsfm_logo class="inline h-10 mr-2 text-white" />
                      </a>

                      <%= if @user_data.steam do %>
                        <a
                          id="steam-link"
                          href={@user_data.steam.profile_url}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <.steam_logo class="inline h-10 mr-2 text-white" />
                        </a>
                      <% end %>

                      <a
                        id="anilist-link"
                        href="https://anilist.co/user/Peekaey/"
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <.anilist_logo class="inline h-10 mr-2 text-white" />
                      </a>

                      <%= if @user_data.osu do %>
                        <a
                          id="osu-link"
                          href={"https://osu.ppy.sh/users/#{@user_data.osu.id}"}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <.osu_logo class="inline h-10 mr-2 text-white" />
                        </a>
                      <% end %>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        <% else %>
          <div class="flex flex-col items-center justify-center h-screen">
            <p class="text-xl font-bold">User data could not be loaded.</p>
            <p class="text-sm text-gray-300 mt-2">Please try refreshing the page.</p>
          </div>
        <% end %>
      </div>
    <% end %>
    """
  end
end
