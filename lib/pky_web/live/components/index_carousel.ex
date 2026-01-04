defmodule PkyWeb.Live.Components.CarouselComponent do
  @moduledoc """
  
  """
  use PkyWeb, :live_component

  # The tabs available to cycle through
  @tabs ["anilist", "spotify", "activities", "steam", "osu"]

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:active_tab, fn -> "anilist" end)}
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
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>

          <div class="min-w-[120px] text-center">
            <h2 class="text-xl font-bold text-white uppercase tracking-widest">
              <%= @active_tab %>
            </h2>
          </div>

          <button
            phx-click="next_tab"
            phx-target={@myself}
            class="p-1 text-gray-400 hover:text-white transition-colors cursor-pointer"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>

        <div class="p-6 text-white text-center">
          <%= case @active_tab do %>
            <% "anilist" -> %>
              <div class="flex flex-col gap-2">
                <span class="text-lg font-semibold text-blue-400">Anilist</span>
                <p class="text-gray-400">Content for Anilist...</p>
              </div>

            <% "spotify" -> %>
              <div class="flex flex-col gap-2">
                <span class="text-lg font-semibold text-green-400">Spotify</span>
                <p class="text-gray-400">Content for Spotify...</p>
              </div>

            <% "activities" -> %>
              <div class="flex flex-col gap-2">
                <span class="text-lg font-semibold text-purple-400">Activities</span>
                <p class="text-gray-400">Content for Activities...</p>
              </div>

            <% "steam" -> %>
              <div class="flex flex-col gap-2">
                <span class="text-lg font-semibold text-slate-400">Steam</span>
                <p class="text-gray-400">Content for Steam...</p>
              </div>

            <% "osu" -> %>
              <div class="flex flex-col gap-2">
                <span class="text-lg font-semibold text-pink-400">Osu!</span>
                <p class="text-gray-400">Content for Osu!...</p>
              </div>
          <% end %>
        </div>

      </div>
    </div>
    """
  end
end
