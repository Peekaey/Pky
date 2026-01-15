defmodule Pky.Models.MioriUserData do
  @moduledoc """
  A complete DTO (Data Transfer Object) for Miori API user data.
  Uses Ecto embedded schemas to parse, validate, and type-cast JSON.
  """
  use Ecto.Schema
  import Ecto.Changeset

  # ============================================================================
  # 1. ROOT SCHEMA
  # ============================================================================

  @primary_key false
  @derive {Jason.Encoder, only: [:discord, :anilist, :spotify, :steam, :osu]}
  embedded_schema do
    embeds_one :discord, __MODULE__.Discord
    embeds_one :anilist, __MODULE__.Anilist
    embeds_one :spotify, __MODULE__.Spotify
    embeds_one :steam, __MODULE__.Steam
    embeds_one :osu, __MODULE__.Osu
  end

  @doc """
  Parses raw map/JSON into a typed Struct.
  Returns {:ok, struct} or {:error, changeset}
  """
  def new(raw_params) do
      # Map the API's "PascalCase" keys to our Schema's "snake_case" keys
      params = %{
        "discord" => raw_params["DiscordUserData"],
        "anilist" => raw_params["AnilistUserData"],
        "spotify" => raw_params["SpotifyUserData"],
        "steam"   => raw_params["SteamUserData"],
        "osu"     => raw_params["OsuUserData"]
      }

      %__MODULE__{}
      # Pass the re-mapped params instead of the raw ones
      |> cast(params, [])
      |> cast_embed(:discord, with: &__MODULE__.Discord.changeset/2)
      |> cast_embed(:anilist, with: &__MODULE__.Anilist.changeset/2)
      |> cast_embed(:spotify, with: &__MODULE__.Spotify.changeset/2)
      |> cast_embed(:steam, with: &__MODULE__.Steam.changeset/2)
      |> cast_embed(:osu, with: &__MODULE__.Osu.changeset/2)
      |> apply_action(:insert)
    end
  @type t :: %__MODULE__{}

  # ============================================================================
  # 2. DISCORD MODULES
  # ============================================================================

  defmodule Discord do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    @derive {Jason.Encoder, only: [:uuid, :global_username, :avatar_url, :banner_url, :created_at, :activities]}
    embedded_schema do
      field :uuid, :integer
      field :global_username, :string
      field :avatar_url, :string
      field :banner_url, :string
      field :created_at, :utc_datetime
      embeds_many :activities, __MODULE__.Activity
    end

    def changeset(schema, params) do
      schema
      |> cast(params, [:uuid, :global_username, :avatar_url, :banner_url, :created_at])
      |> cast_embed(:activities)
    end

    defmodule Activity do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key false
      @derive {Jason.Encoder, only: [:name, :state, :details, :large_text, :large_image, :small_text, :small_image, :activity_type, :timestamp_start_utc, :timestamp_end_utc, :created_at_utc]}
      embedded_schema do
        field :name, :string
        field :state, :string
        field :details, :string
        field :large_text, :string
        field :large_image, :string
        field :small_text, :string
        field :small_image, :string
        field :activity_type, :string
        field :timestamp_start_utc, :utc_datetime
        field :timestamp_end_utc, :utc_datetime
        field :created_at_utc, :utc_datetime
      end

      def changeset(schema, params) do
        cast(schema, params, [
          :name, :state, :details, :large_text, :large_image, :small_text,
          :small_image, :activity_type, :timestamp_start_utc,
          :timestamp_end_utc, :created_at_utc
        ])
      end
    end
  end

  # ============================================================================
  # 3. ANILIST MODULES
  # ============================================================================

  defmodule Anilist do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    @derive {Jason.Encoder, only: [:id, :name, :site_url, :avatar_url, :banner_url, :statistics]}
    embedded_schema do
      field :id, :integer
      field :name, :string
      field :site_url, :string
      field :avatar_url, :string
      field :banner_url, :string
      embeds_one :statistics, __MODULE__.Statistics
    end

    def changeset(schema, params) do
      schema
      |> cast(params, [:id, :name, :site_url, :avatar_url, :banner_url])
      |> cast_embed(:statistics)
    end

    defmodule Statistics do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key false
      @derive {Jason.Encoder, only: [:anime, :manga]}
      embedded_schema do
        embeds_one :anime, __MODULE__.AnimeStats
        embeds_one :manga, __MODULE__.MangaStats
      end

      def changeset(schema, params) do
        schema
        |> cast(params, [])
        |> cast_embed(:anime)
        |> cast_embed(:manga)
      end

      defmodule AnimeStats do
        use Ecto.Schema
        import Ecto.Changeset
        @primary_key false
        @derive {Jason.Encoder, only: [:count, :mean_score, :episodes_watched, :minutes_watched]}
        embedded_schema do
          field :count, :integer
          field :mean_score, :float
          field :episodes_watched, :integer
          field :minutes_watched, :integer
        end
        def changeset(s, p), do: cast(s, p, [:count, :mean_score, :episodes_watched, :minutes_watched])
      end

      defmodule MangaStats do
        use Ecto.Schema
        import Ecto.Changeset
        @primary_key false
        @derive {Jason.Encoder, only: [:count, :mean_score, :chapters_read, :volumes_read]}
        embedded_schema do
          field :count, :integer
          field :mean_score, :float
          field :chapters_read, :integer
          field :volumes_read, :integer
        end
        def changeset(s, p), do: cast(s, p, [:count, :mean_score, :chapters_read, :volumes_read])
      end
    end
  end

  # ============================================================================
  # 4. SPOTIFY MODULES
  # ============================================================================

  defmodule Spotify do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    @derive {Jason.Encoder, only: [:display_name, :profile_url, :avatar_url, :recently_played, :user_playlists]}
    embedded_schema do
      field :display_name, :string
      field :profile_url, :string
      field :avatar_url, :string
      embeds_many :recently_played, __MODULE__.Track
      embeds_many :user_playlists, __MODULE__.Playlist
    end

    def changeset(schema, params) do
      schema
      |> cast(params, [:display_name, :profile_url, :avatar_url])
      |> cast_embed(:recently_played)
      |> cast_embed(:user_playlists)
    end

    defmodule Artist do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
      @derive {Jason.Encoder, only: [:artist_name, :artist_id, :artist_url]}
      embedded_schema do
        field :artist_name, :string
        field :artist_id, :string
        field :artist_url, :string
      end
      def changeset(s, p), do: cast(s, p, [:artist_name, :artist_id, :artist_url])
    end

    defmodule Cover do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
      @derive {Jason.Encoder, only: [:album_url]}
      embedded_schema do
        field :album_url, :string
      end
      def changeset(s, p), do: cast(s, p, [:album_url])
    end

    defmodule Album do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
      @derive {Jason.Encoder, only: [:album_name, :covers]}
      embedded_schema do
        field :album_name, :string
        embeds_many :covers, Pky.Models.MioriUserData.Spotify.Cover
      end
      def changeset(s, p), do: cast(s, p, [:album_name]) |> cast_embed(:covers)
    end

    defmodule Track do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
      @derive {Jason.Encoder, only: [:track_name, :track_id, :track_url, :combined_artists, :played_at_utc, :artists, :album]}
      embedded_schema do
        field :track_name, :string
        field :track_id, :string
        field :track_url, :string
        field :combined_artists, :string
        field :played_at_utc, :utc_datetime
        embeds_many :artists, Pky.Models.MioriUserData.Spotify.Artist
        embeds_one :album, Pky.Models.MioriUserData.Spotify.Album
      end
      def changeset(s, p) do
        cast(s, p, [:track_name, :track_id, :track_url, :combined_artists, :played_at_utc])
        |> cast_embed(:artists)
        |> cast_embed(:album)
      end
    end

    defmodule Playlist do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
      @derive {Jason.Encoder, only: [:playlist_name, :playlist_id, :playlist_url, :playlist_cover_url, :playlist_description, :total_tracks]}
      embedded_schema do
        field :playlist_name, :string
        field :playlist_id, :string
        field :playlist_url, :string
        field :playlist_cover_url, :string
        field :playlist_description, :string
        field :total_tracks, :integer
      end
      def changeset(s, p), do: cast(s, p, [:playlist_name, :playlist_id, :playlist_url, :playlist_cover_url, :playlist_description, :total_tracks])
    end
  end

  # ============================================================================
  # 5. STEAM MODULES
  # ============================================================================

  defmodule Steam do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    @derive {Jason.Encoder, only: [:steamid, :profile_url, :persona_name, :avatar, :last_logoff_utc, :time_created_utc, :recent_games]}
    embedded_schema do
      field :steamid, :string
      field :profile_url, :string
      field :persona_name, :string
      field :avatar, :string
      field :last_logoff_utc, :utc_datetime
      field :time_created_utc, :utc_datetime
      embeds_many :recent_games, __MODULE__.Game
    end

    def changeset(schema, params) do
      schema
      |> cast(params, [:steamid, :profile_url, :persona_name, :avatar, :last_logoff_utc, :time_created_utc])
      |> cast_embed(:recent_games)
    end

    defmodule Game do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
      @derive {Jason.Encoder, only: [:appid, :name, :playtime_2weeks_minutes, :playtime_forever_minutes, :img_icon_url, :img_header_url, :store_url]}
      embedded_schema do
        field :appid, :integer
        field :name, :string
        field :playtime_2weeks_minutes, :integer
        field :playtime_forever_minutes, :integer
        field :img_icon_url, :string
        field :img_header_url, :string
        field :store_url, :string
      end
      def changeset(s, p), do: cast(s, p, [:appid, :name, :playtime_2weeks_minutes, :playtime_forever_minutes, :img_icon_url, :img_header_url, :store_url])
    end
  end

  # ============================================================================
  # 6. OSU MODULES
  # ============================================================================

  defmodule Osu do
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    @derive {Jason.Encoder, only: [:id, :username, :avatar_url, :cover_url, :join_date, :cover, :recent_scores]}
    embedded_schema do
      field :id, :integer
      field :username, :string
      field :avatar_url, :string
      field :cover_url, :string
      field :join_date, :utc_datetime
      field :url, :string
      embeds_one :cover, __MODULE__.Cover
      embeds_many :recent_scores, __MODULE__.Score
    end

    def changeset(schema, params) do
      schema
      |> cast(params, [:id, :username, :avatar_url, :cover_url, :join_date])
      |> cast_embed(:cover)
      |> cast_embed(:recent_scores)
    end

    defmodule Cover do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
      @derive {Jason.Encoder, only: [:url, :custom_url]}
      embedded_schema do
        field :url, :string
        field :custom_url, :string
      end
      def changeset(s, p), do: cast(s, p, [:url, :custom_url])
    end

    defmodule Score do
      use Ecto.Schema
      import Ecto.Changeset
      @primary_key false
      @derive {Jason.Encoder, only: [:id, :score, :accuracy, :max_combo, :rank, :passed, :pp, :mode, :mods, :statistics, :beatmap, :beatmapset]}
      embedded_schema do
        field :id, :integer
        field :score, :integer
        field :accuracy, :float
        field :max_combo, :integer
        field :rank, :string
        field :passed, :boolean
        field :pp, :float
        field :mode, :string
        field :mods, {:array, :string}
        embeds_one :statistics, __MODULE__.Statistics
        embeds_one :beatmap, __MODULE__.Beatmap
        embeds_one :beatmapset, __MODULE__.BeatmapSet
      end

      def changeset(s, p) do
        cast(s, p, [:id, :score, :accuracy, :max_combo, :rank, :passed, :pp, :mode, :mods])
        |> cast_embed(:statistics)
        |> cast_embed(:beatmap)
        |> cast_embed(:beatmapset)
      end

      defmodule Statistics do
        use Ecto.Schema
        import Ecto.Changeset
        @primary_key false
        @derive {Jason.Encoder, only: [:count_300, :count_100, :count_50, :count_miss, :count_katu, :count_geki]}
        embedded_schema do
          field :count_300, :integer
          field :count_100, :integer
          field :count_50, :integer
          field :count_miss, :integer
          field :count_katu, :integer
          field :count_geki, :integer
        end
        def changeset(s, p), do: cast(s, p, [:count_300, :count_100, :count_50, :count_miss, :count_katu, :count_geki])
      end

      defmodule Beatmap do
        use Ecto.Schema
        import Ecto.Changeset
        @primary_key false
        @derive {Jason.Encoder, only: [:id, :url, :version, :mode, :difficulty_rating, :ranked, :bpm, :ar, :accuracy, :drain]}
        embedded_schema do
          field :id, :integer
          field :url, :string
          field :version, :string
          field :mode, :string
          field :difficulty_rating, :float
          field :ranked, :integer
          field :bpm, :float
          field :ar, :float
          field :accuracy, :float
          field :drain, :float
        end
        def changeset(s, p), do: cast(s, p, [:id, :url, :version, :mode, :difficulty_rating, :ranked, :bpm, :ar, :accuracy, :drain])
      end

      defmodule BeatmapSet do
        use Ecto.Schema
        import Ecto.Changeset
        @primary_key false
        @derive {Jason.Encoder, only: [:id, :title, :artist, :creator, :status, :preview_url, :covers]}
        embedded_schema do
          field :id, :integer
          field :title, :string
          field :artist, :string
          field :creator, :string
          field :status, :string
          field :preview_url, :string
          embeds_one :covers, __MODULE__.Covers
        end
        def changeset(s, p), do: cast(s, p, [:id, :title, :artist, :creator, :status, :preview_url]) |> cast_embed(:covers)

        defmodule Covers do
          use Ecto.Schema
          import Ecto.Changeset
          @primary_key false
          @derive {Jason.Encoder, only: [:cover, :cover2x, :card, :card2x, :list, :list2x, :slim_cover, :slim_cover2x]}
          embedded_schema do
            field :cover, :string
            field :cover2x, :string
            field :card, :string
            field :card2x, :string
            field :list, :string
            field :list2x, :string
            field :slim_cover, :string
            field :slim_cover2x, :string
          end
          def changeset(s, p), do: cast(s, p, [:cover, :cover2x, :card, :card2x, :list, :list2x, :slim_cover, :slim_cover2x])
        end
      end
    end
  end
end
