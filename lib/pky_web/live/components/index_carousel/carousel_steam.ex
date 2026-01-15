defmodule PkyWeb.Live.Components.IndexCarousel.CarouselSteam do
  @moduledoc """
  Component for displaying Steam recently played games
  """
  use PkyWeb, :live_component

  @items_per_page 3

  @impl true
  def update(assigns, socket) do
    current_page = socket.assigns[:current_page] || 1


    recent_games = get_recent_games(assigns.user_data)
    total_pages = calculate_total_pages(recent_games)
    current_page = max(1, min(current_page, max(1, total_pages)))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_page, current_page)
     |> assign(:total_pages, total_pages)
     |> assign(:paginated_games, paginate_games(recent_games, current_page))}
  end

  @impl true
  def handle_event("goto_page", %{"page" => page}, socket) do
    new_page = String.to_integer(page)
    recent_games = get_recent_games(socket.assigns.user_data)

    {:noreply,
     socket
     |> assign(:current_page, new_page)
     |> assign(:paginated_games, paginate_games(recent_games, new_page))}
  end

  defp get_recent_games(%{steam: %{recent_games: games}}) when is_list(games), do: games
  defp get_recent_games(_), do: []

  defp calculate_total_pages([]), do: 1
  defp calculate_total_pages(games), do: ceil(length(games) / @items_per_page)

  defp paginate_games(games, page) do
    start_index = (page - 1) * @items_per_page
    Enum.slice(games, start_index, @items_per_page)
  end

  defp format_hours(minutes) do
    hours = minutes / 60
    :erlang.float_to_binary(hours, [decimals: 1]) <> " hrs"
  end

  @impl true
@impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center w-full">
      <%= if @user_data && @user_data.steam do %>

        <%= if length(@paginated_games) > 0 do %>

          <div class="flex flex-col gap-3 w-full items-center min-h-[350px]">
            <%= for game <- @paginated_games do %>
              <.game_card game={game} />
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
                  if(@current_page == page, do: "w-6 bg-white", else: "w-2 bg-gray-600 hover:bg-gray-500")
                ]}
                aria-label={"Page #{page}"}
              >
              </button>
            <% end %>
          </div>

        <% else %>
          <div class="flex flex-col items-center justify-center min-h-[350px] w-full max-w-sm rounded-lg p-4 text-center">
            <p class="text-gray-400 italic text-sm">No recently played games...</p>
          </div>
        <% end %>
      <% else %>
        <div class="flex flex-col items-center justify-center min-h-[350px]">
          <p class="text-gray-400">Unable to get Steam data...</p>
        </div>
      <% end %>
    </div>
    """
  end

  def game_card(assigns) do
      ~H"""
      <.link
        href={@game.store_url}
        class="block bg-gray-800/50 rounded-lg p-3 w-full max-w-sm border border-gray-700 hover:bg-gray-700/50 transition-colors"
      >
        <div class="flex gap-4">

          <div class="relative flex-shrink-0 w-16 h-16">
            <img
              src={@game.img_icon_url}
              alt={@game.name}
              class="w-full h-full rounded-lg object-cover shadow-sm"
            />
          </div>

          <div class="flex flex-col justify-center min-w-0 flex-1">
            <h4 class="text-sm text-white font-bold truncate mb-1"><%= @game.name %></h4>

            <div class="flex flex-col gap-0.5">
              <div class="flex items-center justify-between text-xs">
                <span class="text-gray-400">Hours Last 2 Weeks:</span>
                <span class="text-gray-250 font-mono"><%= format_hours(@game.playtime_2weeks_minutes) %></span>
              </div>

              <div class="flex items-center justify-between text-xs">
                <span class="text-gray-500">Total Played:</span>
                <span class="text-gray-300 font-mono"><%= format_hours(@game.playtime_forever_minutes) %></span>
              </div>
            </div>
          </div>
        </div>
      </.link>
      """
    end
end
