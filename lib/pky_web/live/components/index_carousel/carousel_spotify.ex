defmodule PkyWeb.Live.Components.IndexCarousel.CarouselSpotify do
  @moduledoc """
  Component for displaying Spotify recently listened to activity
  """
  use PkyWeb, :live_component

  @items_per_page 3

  @impl true
  def update(assigns, socket) do
    current_page = assigns[:current_page] || socket.assigns[:current_page] || 1

    recent_played = get_recent_played(assigns.user_data)
    total_pages = calculate_total_pages(recent_played)
    current_page = max(1, min(current_page, max(1, total_pages)))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_page, current_page)
     |> assign(:total_pages, total_pages)
     |> assign(:paginated_played, paginate_played(recent_played, current_page))}
  end

  @impl true
  def handle_event("goto_page", %{"page" => page}, socket) do
    new_page = String.to_integer(page)
    {:noreply, assign(socket, :current_page, new_page) |> update_pagination()}
  end

  defp update_pagination(socket) do
    recent_played = get_recent_played(socket.assigns.user_data)
    assign(socket, :paginated_played, paginate_played(recent_played, socket.assigns.current_page))
  end

  defp get_recent_played(user_data) do
    case user_data do
      %{spotify: %{recently_played: played}} when is_list(played) -> played
      _ -> []
    end
  end

  defp calculate_total_pages([]), do: 1
  defp calculate_total_pages(items), do: ceil(length(items) / @items_per_page)

  defp paginate_played(played, page) do
    Enum.slice(played, (page - 1) * @items_per_page, @items_per_page)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center w-full">
      <%= if @user_data && @user_data.spotify do %>
        <%= if length(@paginated_played) > 0 do %>
          <div class="flex flex-col gap-3 w-full items-center justify-center min-h-[350px]">
            <%= for recent_played <- @paginated_played do %>
              <.recently_played recently_played={recent_played} />
            <% end %>
          </div>

          <%= if @total_pages > 1 do %>
            <div class="flex items-center justify-center gap-1 mt-3">
              <%= for page <- 1..@total_pages do %>
                <button
                  phx-click="goto_page"
                  phx-value-page={page}
                  phx-target={@myself}
                  class={[
                    "h-2 rounded-full transition-all duration-300",
                    if(@current_page == page,
                      do: "w-6 bg-white",
                      else: "w-2 bg-gray-600 hover:bg-gray-500"
                    )
                  ]}
                  aria-label={"Go to page #{page}"}
                >
                </button>
              <% end %>
            </div>
          <% end %>
        <% else %>
          <div class="w-full max-w-sm rounded-lg p-4 text-center">
            <p class="text-gray-400 italic text-sm">No recently played tracks...</p>
          </div>
        <% end %>
      <% else %>
        <p class="text-gray-400 text-sm">Unable to get Spotify data...</p>
      <% end %>
    </div>
    """
  end

  attr :recently_played, :map, required: true

  def recently_played(assigns) do
    ~H"""
    <.link
    href={@recently_played.track_url}
    class="bg-gray-800/30 border border-gray-700/50 rounded-lg p-3 w-full max-w-sm transition-all hover:bg-gray-800/50"
    >
    <div class="">
      <div class="flex gap-3">
        <div class="relative flex-shrink-0 w-16 h-16">
          <img
            src={get_album_art(@recently_played)}
            alt={@recently_played.track_name}
            class="w-full h-full rounded shadow-md object-cover"
          />
        </div>

        <div class="flex flex-col min-w-0 flex-1 gap-0.5 justify-center">
          <div class="text-sm text-white font-bold truncate leading-tight">
            {@recently_played.track_name}
          </div>
          <div class="text-xs text-gray-400 truncate">
            by <span class="text-gray-300">{@recently_played.combined_artists}</span>
          </div>
          <div class="text-xs text-gray-400 truncate">
            <span>{@recently_played.album.album_name}</span>
          </div>
          <div class="flex items-center justify-center gap-1 mt-1 text-[10px] text-gray-500 font-mono">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-3 w-3"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"
                clip-rule="evenodd"
              />
            </svg>
            <span>{format_time_ago(@recently_played.played_at_utc)}</span>
          </div>
        </div>
      </div>
    </div>
    </.link>
    """
  end

  defp get_album_art(track) do
    case track.album do
      %{covers: [first | _]} -> first.album_url
      _ -> ""
    end
  end

  defp format_time_ago(nil), do: ""

  defp format_time_ago(datetime) do
    now = DateTime.utc_now()
    diff_seconds = DateTime.diff(now, datetime)

    cond do
      diff_seconds < 60 -> "Just now"
      diff_seconds < 3600 -> "#{div(diff_seconds, 60)}m ago"
      diff_seconds < 86400 -> "#{div(diff_seconds, 3600)}h ago"
      true -> "#{div(diff_seconds, 86400)}d ago"
    end
  end
end
