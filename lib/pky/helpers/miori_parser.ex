  defmodule Pky.Helpers.MioriParser do
  @moduledoc """
  Helper module for parsing Miori API responses.
  """

alias Pky.Models.MioriTypes

@spec parse_user_data(map()) :: MioriTypes.user_data()
  def parse_user_data(raw_data) do
    %{
      discord: parse_discord(raw_data["DiscordUserData"]),
      anilist: parse_anilist(raw_data["AnilistUserData"]),
      spotify: parse_spotify(raw_data["SpotifyUserData"]),
      steam: parse_steam(raw_data["SteamUserData"]),
      osu: parse_osu(raw_data["OsuUserData"])
    }
  end

  defp parse_discord(nil), do: nil
  defp parse_discord(data) do
    %{
      uuid: data["uuid"],
      banner_url: data["banner_url"],
      avatar_url: data["avatar_url"],
      global_username: data["global_username"],
      created_at: parse_datetime(data["created_at"]),
      activities: Enum.map(data["activities"] || [], &parse_activity/1)
    }
  end

  defp parse_activity(activity) do
    %{
      name: activity["name"],
      state: activity["state"],
      details: activity["details"],
      large_text: activity["large_text"],
      large_image: activity["large_image"],
      small_image: activity["small_image"],
      small_text: activity["small_text"],
      timestamp_start_utc: parse_datetime(activity["timestamp_start_utc"]),
      timestamp_end_utc: parse_datetime(activity["timestamp_end_utc"]),
      activity_type: activity["activity_type"],
      created_at_utc: parse_datetime(activity["created_at_utc"])
    }
  end

  defp parse_anilist(nil), do: nil
  defp parse_anilist(data) do
    %{
      id: data["id"],
      name: data["name"],
      site_url: data["siteUrl"],
      avatar_url: data["avatar_url"],
      banner_url: data["banner_url"],
      statistics: parse_anilist_stats(data["statistics"])
    }
  end

  defp parse_anilist_stats(stats) do
    %{
      anime: %{
        count: stats["anime"]["count"],
        mean_score: stats["anime"]["mean_score"],
        episodes_watched: stats["anime"]["episodes_watched"],
        minutes_watched: stats["anime"]["minutes_watched"]
      },
      manga: %{
        chapters_read: stats["manga"]["chapters_read"],
        volumes_read: stats["manga"]["volumes_read"],
        count: stats["manga"]["count"],
        mean_score: stats["manga"]["mean_score"]
      }
    }
  end

  defp parse_spotify(nil), do: nil
  defp parse_spotify(data) do
    %{
      display_name: data["display_name"],
      profile_url: data["profile_url"],
      avatar_url: data["avatar_url"],
      recently_played: Enum.map(data["recently_played"] || [], &parse_track/1),
      user_playlists: Enum.map(data["user_playlists"] || [], &parse_playlist/1)
    }
  end

  defp parse_track(track) do
    %{
      track_name: track["track_name"],
      track_id: track["track_id"],
      track_url: track["track_url"],
      played_at_utc: parse_datetime(track["played_at_utc"]),
      artists: Enum.map(track["artists"] || [], &parse_artist/1),
      combined_artists: track["combined_artists"]
    }
  end

  defp parse_artist(artist) do
    %{
      artist_name: artist["artist_name"],
      artist_id: artist["artist_id"],
      artist_url: artist["artist_url"]
    }
  end

  defp parse_playlist(playlist) do
    %{
      playlist_name: playlist["playlist_name"],
      playlist_id: playlist["playlist_id"],
      playlist_url: playlist["playlist_url"],
      playlist_cover_url: playlist["playlist_cover_url"],
      playlist_description: playlist["playlist_description"],
      total_tracks: playlist["total_tracks"]
    }
  end

  defp parse_steam(nil), do: nil
  defp parse_steam(data) do
    %{
      steamid: data["steamid"],
      profile_url: data["profile_url"],
      persona_name: data["persona_name"],
      avatar: data["avatar"],
      last_logoff_utc: parse_datetime(data["last_logoff_utc"]),
      time_created_utc: parse_datetime(data["time_created_utc"]),
      recent_games: Enum.map(data["recent_games"] || [], &parse_steam_game/1)
    }
  end

  defp parse_steam_game(game) do
    %{
      appid: game["appid"],
      name: game["name"],
      playtime_2weeks_minutes: game["playtime_2weeks_minutes"],
      playtime_forever_minutes: game["playtime_forever_minutes"],
      img_icon_url: game["img_icon_url"],
      img_header_url: game["img_header_url"]
    }
  end

  defp parse_osu(nil), do: nil
  defp parse_osu(data) do
    %{
      id: data["id"],
      avatar_url: data["avatar_url"],
      cover_url: data["cover_url"],
      username: data["username"],
      join_date: parse_datetime(data["join_date"]),
      cover: parse_osu_cover(data["cover"]),
      recent_scores: Enum.map(data["recentScores"] || [], &parse_osu_score/1)
    }
  end

  defp parse_osu_cover(cover) do
    %{
      custom_url: cover["custom_url"],
      url: cover["url"]
    }
  end

  defp parse_osu_score(score) do
    %{
      accuracy: score["accuracy"],
      id: score["id"],
      max_combo: score["max_combo"],
      mode: score["mode"],
      mods: score["mods"] || [],
      passed: score["passed"],
      pp: score["pp"],
      rank: score["rank"],
      score: score["score"],
      statistics: parse_osu_statistics(score["statistics"]),
      beatmap: parse_osu_beatmap(score["beatmap"]),
      beatmap_set: parse_osu_beatmap_set(score["beatmapSet"])
    }
  end

  defp parse_osu_statistics(stats) do
    %{
      count_100: stats["count_100"],
      count_300: stats["count_300"],
      count_50: stats["count_50"],
      count_geki: stats["count_geki"],
      count_katu: stats["count_katu"],
      count_miss: stats["count_miss"]
    }
  end

  defp parse_osu_beatmap(beatmap) do
    %{
      difficulty_rating: beatmap["difficulty_rating"],
      id: beatmap["id"],
      mode: beatmap["mode"],
      ranked: beatmap["ranked"],
      version: beatmap["version"],
      accuracy: beatmap["accuracy"],
      ar: beatmap["ar"],
      bpm: beatmap["bpm"],
      drain: beatmap["drain"],
      url: beatmap["url"]
    }
  end

  defp parse_osu_beatmap_set(beatmap_set) do
    %{
      artist: beatmap_set["artist"],
      creator: beatmap_set["creator"],
      id: beatmap_set["id"],
      title: beatmap_set["title"],
      status: beatmap_set["status"],
      preview_url: beatmap_set["preview_url"],
      covers: parse_osu_covers(beatmap_set["covers"])
    }
  end

  defp parse_osu_covers(covers) do
    %{
      cover: covers["cover"],
      cover2x: covers["cover2x"],
      card: covers["card"],
      card2x: covers["card2x"],
      list: covers["list"],
      list2x: covers["list2x"],
      slim_cover: covers["slimCover"],
      slim_cover2x: covers["slimCover2x"]
    }
  end

  defp parse_datetime(nil), do: nil
  defp parse_datetime(str) when is_binary(str) do
    case DateTime.from_iso8601(str) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end
end
