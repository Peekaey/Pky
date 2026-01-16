defmodule PkyWeb.Live.Components.IndexCarousel.CarouselOsu do
  @moduledoc """
  Carousel component for displaying Osu! recently played beatmaps/scores
  """
  use PkyWeb, :live_component

  @items_per_page 3

  @impl true
  def update(assigns, socket) do
    current_page = assigns[:current_page] || socket.assigns[:current_page] || 1

    recent_beatmaps = get_recent_beatmaps(assigns.user_data)
    total_pages = calculate_total_pages(recent_beatmaps)
    current_page = max(1, min(current_page, max(1, total_pages)))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_page, current_page)
     |> assign(:total_pages, total_pages)
     |> assign(:paginated_beatmaps, paginate_beatmaps(recent_beatmaps, current_page))}
  end

  @impl true
  def handle_event("goto_page", %{"page" => page}, socket) do
    new_page = String.to_integer(page)
    {:noreply, assign(socket, :current_page, new_page) |> update_pagination()}
  end

  defp update_pagination(socket) do
    recent_beatmaps = get_recent_beatmaps(socket.assigns.user_data)

    assign(
      socket,
      :paginated_beatmaps,
      paginate_beatmaps(recent_beatmaps, socket.assigns.current_page)
    )
  end

  defp get_recent_beatmaps(user_data) do
    case user_data do
      %{osu: %{recent_scores: beatmaps}} when is_list(beatmaps) -> beatmaps
      _ -> []
    end
  end

  defp calculate_total_pages([]), do: 1
  defp calculate_total_pages(beatmaps), do: ceil(length(beatmaps) / @items_per_page)

  defp paginate_beatmaps(beatmaps, page) do
    Enum.slice(beatmaps, (page - 1) * @items_per_page, @items_per_page)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center w-full">
      <%= if @user_data && @user_data.osu do %>
        <%= if length(@paginated_beatmaps) > 0 do %>

          <div class="flex flex-col gap-3 w-full justify-center items-center min-h-[350px]">
            <%= for recent_beatmap <- @paginated_beatmaps do %>
              <.activity beatmap={recent_beatmap} />
            <% end %>
          </div>

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
        <% else %>
          <div class="flex flex-col items-center justify-center min-h-[350px] w-full max-w-sm rounded-lg p-4 text-center">
            <p class="text-gray-400 italic text-sm">No recent plays found...</p>
          </div>
        <% end %>
      <% else %>
        <div class="flex flex-col items-center justify-center min-h-[350px]">
          <p class="text-gray-400 text-sm">Unable to get Osu data...</p>
        </div>
      <% end %>
    </div>
    """
  end

  attr :beatmap, :map, required: true

  def activity(assigns) do
    ~H"""
    <.link
    href={@beatmap.beatmap.url}
    class="bg-gray-800/30 border border-gray-700/50 rounded-lg p-3 w-full max-w-sm transition-all hover:bg-gray-800/50"
    >
    <div class="">
      <div class="flex gap-3">
        <div class="relative flex-shrink-0 w-16 h-16">
          <img
            src={get_beatmap_cover(@beatmap)}
            alt={@beatmap.beatmapset.title}
            class="w-full h-full rounded shadow-md object-cover grayscale-[0.2]"
          />
        </div>

        <div class="flex flex-col min-w-0 flex-1 gap-0.5 justify-center">
          <span class="text-[10px] text-gray-400 font-bold uppercase tracking-wider">
            Recent Played
          </span>

          <div class="text-sm text-white font-bold truncate leading-tight">
            {@beatmap.beatmapset.title}
          </div>

          <div class="text-xs text-gray-400 truncate">
            by <span class="text-gray-300">{@beatmap.beatmapset.artist}</span>
          </div>

          <div class="flex items-center gap-3 mt-1 text-[10px] font-mono text-gray-400">
            <span class="flex items-center gap-1 text-gray-300 font-bold">
              <span>★</span> {format_number(@beatmap.beatmap.difficulty_rating)}
            </span>
            <span class="w-px h-3 bg-gray-700"></span>
            <span>{@beatmap.rank}</span>
            <span class="w-px h-3 bg-gray-700"></span>
            <span class="">{round(@beatmap.pp || 0)}pp</span>
            <span class="w-px h-3 bg-gray-700"></span>
            <span>{format_accuracy(@beatmap.accuracy)}</span>
            <span class="w-px h-3 bg-gray-700"></span>
            <span>{@beatmap.max_combo}x</span>
          </div>
        </div>
      </div>
    </div>
    </.link>
    """
  end

  defp get_beatmap_cover(beatmap) do
    case beatmap.beatmapset do
      %{covers: %{list: url}} when is_binary(url) -> url
      _ -> ""
    end
  end

  defp format_number(nil), do: "0.00"
  defp format_number(num) when is_float(num), do: :erlang.float_to_binary(num, decimals: 2)
  defp format_number(num), do: num

  defp format_accuracy(nil), do: "0.00%"

  defp format_accuracy(acc) when acc <= 1 do
    percentage = acc * 100
    "#{:erlang.float_to_binary(percentage, decimals: 2)}%"
  end

  defp format_accuracy(acc) do
    "#{:erlang.float_to_binary(acc / 1, decimals: 2)}%"
  end
end
