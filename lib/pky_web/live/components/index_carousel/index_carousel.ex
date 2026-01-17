defmodule PkyWeb.Live.Components.CarouselComponent do
  @moduledoc """
  Main carousel container that switches between different services.
  """
  use PkyWeb, :live_component

  alias PkyWeb.Live.Components.IndexCarousel.{
    CarouselDiscord,
    CarouselSteam,
    CarouselOsu,
    CarouselSpotify,
    CarouselAnilist
  }

  @tabs ["activities", "spotify", "steam", "osu", "anilist"]

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     # Keeps the tab active if the parent LiveView refreshes user_data
     |> assign_new(:active_tab, fn -> "activities" end)}
  end

  @impl true
  def handle_event("next_tab", _params, socket) do
    current_index = Enum.find_index(@tabs, &(&1 == socket.assigns.active_tab))
    next_index = rem(current_index + 1, length(@tabs))
    next_tab = Enum.at(@tabs, next_index)
    {:noreply, assign(socket, active_tab: next_tab)}
  end

  @impl true
  def handle_event("prev_tab", _params, socket) do
    current_index = Enum.find_index(@tabs, &(&1 == socket.assigns.active_tab))
    prev_index = rem(current_index - 1 + length(@tabs), length(@tabs))
    prev_tab = Enum.at(@tabs, prev_index)
    {:noreply, assign(socket, active_tab: prev_tab)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full bg-transparent border-none">
      <div class="flex flex-col">
        <div class="flex items-center justify-center gap-6 py-4">
          <button
            phx-click="prev_tab"
            phx-target={@myself}
            class="p-1 text-gray-400 hover:text-white transition-colors cursor-pointer"
            aria-label="Previous Tab"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              />
            </svg>
          </button>

          <div class="min-w-[140px] text-center">
            <h2 class="text-xl font-bold text-white uppercase tracking-widest select-none">
              {@active_tab}
            </h2>
          </div>

          <button
            phx-click="next_tab"
            phx-target={@myself}
            class="p-1 text-gray-400 hover:text-white transition-colors cursor-pointer"
            aria-label="Next Tab"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>

        <div class="p-6 text-white text-center h-[375px]  flex items-center justify-center">
          <%= case @active_tab do %>
            <% "activities" -> %>
              <div class="w-full">
                <.live_component
                  module={CarouselDiscord}
                  id="carousel-discord"
                  user_data={@user_data}
                />
              </div>
            <% "spotify" -> %>
              <div class="w-full">
                <.live_component
                  module={CarouselSpotify}
                  id="carousel-spotify"
                  user_data={@user_data}
                />
              </div>
            <% "steam" -> %>
              <div class="w-full">
                <.live_component
                  module={CarouselSteam}
                  id="carousel-steam"
                  user_data={@user_data}
                />
              </div>
            <% "osu" -> %>
              <div class="w-full">
                <.live_component
                  module={CarouselOsu}
                  id="carousel-osu"
                  user_data={@user_data}
                />
              </div>
            <% "anilist" -> %>
              <div class="w-full">
                <.live_component
                  module={CarouselAnilist}
                  id="carousel-anilist"
                  user_data={@user_data}
                />
              </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
