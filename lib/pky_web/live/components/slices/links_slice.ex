defmodule PkyWeb.Live.Components.LinksSlice do
  @moduledoc """

  """
  use PkyWeb, :live_component
  import PkyWeb.Live.Components.SvgComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <a
        id="discord-link"
        href="https://discord.com/users/181661376584876032"
        target="_blank"
        rel="noopener noreferrer"
      >
        <.discord_logo class="inline h-8 mr-2 text-white" />
      </a>

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

      <a
        id="steam-link"
        href="https://steamcommunity.com/id/Peekaey"
        target="_blank"
        rel="noopener noreferrer"
      >
        <.steam_logo class="inline h-10 mr-2 text-white" />
      </a>

      <a
        id="anilist-link"
        href="https://anilist.co/user/Peekaey/"
        target="_blank"
        rel="noopener noreferrer"
      >
        <.anilist_logo class="inline h-10 mr-2 text-white" />
      </a>

      <a
        id="osu-link"
        href="https://osu.ppy.sh/users/8611494"
        target="_blank"
        rel="noopener noreferrer"
      >
        <.osu_logo class="inline h-10 mr-2 text-white" />
      </a>
    </div>
    """
  end
end
