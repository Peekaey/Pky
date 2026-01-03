defmodule Pky.Models.MioriTypes do
  @moduledoc """
  Module defining types for Miori API data structures.
  """
  use Ecto.Schema

  # Main response type
  @type user_data :: %{
    discord: discord_user() | nil,
    anilist: anilist_user() | nil,
    spotify: spotify_user() | nil,
    steam: steam_user() | nil,
    osu: osu_user() | nil
  }

  # Discord Types
  @type discord_user :: %{
    uuid: integer(),
    banner_url: String.t(),
    avatar_url: String.t(),
    global_username: String.t(),
    created_at: DateTime.t(),
    activities: list(discord_activity())
  }

  @type discord_activity :: %{
    name: String.t(),
    state: String.t(),
    details: String.t(),
    large_text: String.t(),
    large_image: String.t(),
    small_image: String.t(),
    small_text: String.t(),
    timestamp_start_utc: DateTime.t(),
    timestamp_end_utc: DateTime.t(),
    activity_type: String.t(),
    created_at_utc: DateTime.t()
  }

  # Anilist Types
  @type anilist_user :: %{
    id: integer(),
    name: String.t(),
    site_url: String.t(),
    avatar_url: String.t(),
    banner_url: String.t(),
    statistics: anilist_statistics()
  }

  @type anilist_statistics :: %{
    anime: anime_stats(),
    manga: manga_stats()
  }

  @type anime_stats :: %{
    count: integer(),
    mean_score: float(),
    episodes_watched: integer(),
    minutes_watched: integer()
  }

  @type manga_stats :: %{
    chapters_read: integer(),
    volumes_read: integer(),
    count: integer(),
    mean_score: float()
  }

  # Spotify Types
  @type spotify_user :: %{
    display_name: String.t(),
    profile_url: String.t(),
    avatar_url: String.t(),
    recently_played: list(spotify_track()),
    user_playlists: list(spotify_playlist())
  }

  @type spotify_track :: %{
    track_name: String.t(),
    track_id: String.t(),
    track_url: String.t(),
    played_at_utc: DateTime.t(),
    artists: list(spotify_artist()),
    combined_artists: String.t()
  }

  @type spotify_artist :: %{
    artist_name: String.t(),
    artist_id: String.t(),
    artist_url: String.t()
  }

  @type spotify_playlist :: %{
    playlist_name: String.t(),
    playlist_id: String.t(),
    playlist_url: String.t(),
    playlist_cover_url: String.t(),
    playlist_description: String.t(),
    total_tracks: integer()
  }

  # Steam Types
  @type steam_user :: %{
    steamid: String.t(),
    profile_url: String.t(),
    persona_name: String.t(),
    avatar: String.t(),
    last_logoff_utc: DateTime.t(),
    time_created_utc: DateTime.t(),
    recent_games: list(steam_game())
  }

  @type steam_game :: %{
    appid: integer(),
    name: String.t(),
    playtime_2weeks_minutes: integer(),
    playtime_forever_minutes: integer(),
    img_icon_url: String.t(),
    img_header_url: String.t()
  }

  # Osu Types
  @type osu_user :: %{
    id: integer(),
    avatar_url: String.t(),
    cover_url: String.t(),
    username: String.t(),
    join_date: DateTime.t(),
    cover: osu_cover(),
    recent_scores: list(osu_score())
  }

  @type osu_cover :: %{
    custom_url: String.t(),
    url: String.t()
  }

  @type osu_score :: %{
    accuracy: float(),
    id: integer(),
    max_combo: integer(),
    mode: String.t(),
    mods: list(String.t()),
    passed: boolean(),
    pp: float(),
    rank: String.t(),
    score: integer(),
    statistics: osu_statistics(),
    beatmap: osu_beatmap(),
    beatmap_set: osu_beatmap_set()
  }

  @type osu_statistics :: %{
    count_100: integer(),
    count_300: integer(),
    count_50: integer(),
    count_geki: integer() | nil,
    count_katu: integer() | nil,
    count_miss: integer()
  }

  @type osu_beatmap :: %{
    difficulty_rating: float(),
    id: integer(),
    mode: String.t(),
    ranked: integer(),
    version: String.t(),
    accuracy: integer(),
    ar: integer(),
    bpm: integer(),
    drain: integer(),
    url: String.t()
  }

  @type osu_beatmap_set :: %{
    artist: String.t(),
    creator: String.t(),
    id: integer(),
    title: String.t(),
    status: String.t(),
    preview_url: String.t(),
    covers: osu_covers()
  }

  @type osu_covers :: %{
    cover: String.t(),
    cover2x: String.t() | nil,
    card: String.t(),
    card2x: String.t() | nil,
    list: String.t(),
    list2x: String.t() | nil,
    slim_cover: String.t(),
    slim_cover2x: String.t() | nil
  }
end
