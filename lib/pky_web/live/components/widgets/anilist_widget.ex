defmodule PkyWeb.Live.Components.Widgets.AnilistWidget do
  use PkyWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="flex flex-row gap-3 w-full items-center">
      <% # Anime Card %>
      <div class="bg-gray-800/30 border border-gray-700/50 rounded-lg p-3 w-full max-w-sm">
        <div class="flex gap-3">

          <div class="flex flex-col min-w-0 flex-1 gap-0.5 justify-center">
            <span class="text-[10px] text-gray-400 font-bold uppercase tracking-wider">
              Anime Progress
            </span>
            <div class="text-sm text-white font-bold truncate">
              <%= @user_data.anilist.statistics.anime.count %> Titles Watched
            </div>
            <div class="text-xs text-gray-300 truncate">
              <%= format_days(@user_data.anilist.statistics.anime.minutes_watched) %> spent • <%= @user_data.anilist.statistics.anime.mean_score %>% Mean
            </div>
          </div>
        </div>
      </div>

      <% # Manga Card %>
      <div class="bg-gray-800/30 border border-gray-700/50 rounded-lg p-3 w-full max-w-sm">
        <div class="flex gap-3">

          <div class="flex flex-col min-w-0 flex-1 gap-0.5 justify-center">
            <span class="text-[10px] text-gray-400 font-bold uppercase tracking-wider">
              Manga Progress
            </span>
            <div class="text-sm text-white font-bold truncate">
              <%= @user_data.anilist.statistics.manga.count %> Titles Read
            </div>
            <div class="text-xs text-gray-300 truncate">
              <%= @user_data.anilist.statistics.manga.chapters_read %> Chapters • <%= @user_data.anilist.statistics.manga.mean_score %>% Mean
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_days(minutes) do
    days = minutes / 1440
    :erlang.float_to_binary(days, [decimals: 1]) <> "d"
  end
end
