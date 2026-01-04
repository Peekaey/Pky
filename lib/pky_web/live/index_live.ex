defmodule PkyWeb.IndexLive do
  @moduledoc """
  LiveView for the index/home page.
  """

  use PkyWeb, :live_view
  use Phoenix.VerifiedRoutes,
    endpoint: PkyWeb.Endpoint,
    router: PkyWeb.Router,
    statics: PkyWeb.static_paths()

  alias Pky.BusinessService.ApiBusinessService
  alias PkyWeb.Live.Components.LoadingComponent
  alias PkyWeb.Live.Components.CarouselComponent
  import PkyWeb.Live.Components.SvgComponents

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Home")
      |> assign(:user_data, nil)
      |> assign(:loading, true)

    # Fetch data asynchronously after mount
    if connected?(socket) do
      send(self(), :fetch_user_data)
    end

    {:ok, socket}
  end

  @impl true
  @spec handle_info(:fetch_user_data, map()) :: {:noreply, map()}
  def handle_info(:fetch_user_data, socket) do
    socket =
      case ApiBusinessService.get_user_data() do
        {:ok, %{discord: _, anilist: _, spotify: _, steam: _, osu: _} = user_data} ->
          socket
          |> assign(:user_data, user_data)
          |> assign(:loading, false)

        {:error, reason} ->
          Logger.error("Failed to fetch user data: #{inspect(reason)}")

          socket
          |> assign(:user_data, nil)
          |> assign(:loading, false)
      end

    {:noreply, socket}
  end



@impl true
def render(assigns) do
  ~H"""
  <%= if @loading do %>
    <LoadingComponent.loading_screen />
  <% else %>
  <div
    class="bg-cover bg-center bg-no-repeat min-h-screen text-white p-6"
    style={"background-image: url('#{~p"/images/gifs/city-pixel-noon.gif"}')"}>
      <%= if @user_data do %>
        <div id="index-content">
          <div id="index-centre-container" class="justify-center flex">
            <div class="border-gray-500 border-4 p-2 rounded-xl max-w-5xl w-full bg-gray-40/50 backdrop-blur-xl">
              <div id="index-inside-centre-container">
                <div id="index-centre-container-header" class="flex flex-col items-center">
                  <img src={~p"/images/icon.jpg"} alt="Discord Avatar" class="rounded-xl w-32 h-32 mt-4" />
                  <h2 class="text-2xl font-bold mt-4"><%= @user_data.discord.global_username %></h2>
                  <p class="text-md mt-2"> Just a random individual among the sea of people on the internet.</p>
                  <p class="text-md mt-2"> Enjoy selfhosting and occasional doer of things  </p>
                </div>

                <div id="index-centre-container-carousel" class="mt-6">
                <.live_component
                  module={CarouselComponent}
                  id="user-carousel"
                  user_data={@user_data}
                />
                </div>

                <div id="index-centre-container-service-status" class="mt-6 flex flex-col items-center">
                  <h3 class="text-xl font-bold mb-4">Service Status</h3>
                  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                  </div>
                </div>

                <div id="index-centre-container-technologies" class="mt-6 flex flex-col items-center">
                  <h3 class="text-xl font-bold mb-4">Technologies</h3>
                  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                  </div>
                </div>

                <div id="index-centre-container-footer" class="mt-6 text-gray-300 justify-center flex flex-col items-center">
                  <h3 class="text-xl font-bold">Links</h3>
                  <div id="index-centre-container-footer-links" class="mt-5 mb-5">
                  <a id="discord-link" href={"https://discord.com/users/#{@user_data.discord.uuid}"} target="_blank" rel="noopener noreferrer">
                    <.discord_logo class="inline h-10 mr-2 text-white" />
                  </a>
                  <a id="github-link" href="https://github.com/Peekaey" target="_blank" rel="noopener noreferrer">
                    <.github_logo class="inline h-10 mr-2 text-white" />
                  </a>
                  <a id="statsfm-link" href="https://stats.fm/peekaey" target="_blank" rel="noopener noreferrer">
                    <.statsfm_logo class="inline h-10 mr-2 text-white" />
                  </a>
                  <a id="anilist-link" href={"https://anilist.co/user/#{@user_data.anilist.name}"} target="_blank" rel="noopener noreferrer">
                    <.anilist_logo class="inline h-10 mr-2 text-white" />
                  </a>
                  <a id="steam-link" href={"#{@user_data.steam.profile_url}"} target="_blank" rel="noopener noreferrer">
                    <.steam_logo class="inline h-10 mr-2 text-white" />
                  </a>
                  <a id="osu-link" href={"https://osu.ppy.sh/users/#{@user_data.osu.id}"} target="_blank" rel="noopener noreferrer">
                    <.osu_logo class="inline h-10 mr-2 text-white" />
                  </a>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% else %>
        <p>Could not load user data</p>
      <% end %>
    </div>
  <% end %>
  """
end

end
