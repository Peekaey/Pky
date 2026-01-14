defmodule PkyWeb.Live.Components.IndexCarousel.CarouselDiscord do
  @moduledoc """
  Carousel component for displaying Discord activity data
  """
  use PkyWeb, :live_component

  @items_per_page 2

  @impl true
  def update(assigns, socket) do

    current_page = assigns[:current_page] || socket.assigns[:current_page] || 1
    activities = get_activities(assigns.user_data)
    total_pages = calculate_total_pages(activities)
    current_page = max(1, min(current_page, max(1, total_pages)))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:current_page, current_page)
     |> assign(:total_pages, total_pages)
     |> assign(:paginated_activities, paginate(activities, current_page))}
  end

  @impl true
  def handle_event("goto_page", %{"page" => page}, socket) do
    new_page = String.to_integer(page)
    {:noreply, assign(socket, :current_page, new_page) |> update_pagination()}
  end

  defp update_pagination(socket) do
    activities = get_activities(socket.assigns.user_data)
    assign(socket, :paginated_activities, paginate(activities, socket.assigns.current_page))
  end

  defp get_activities(user_data) do
    case user_data do
      %{discord: %{activities: activities}} when is_list(activities) -> activities
      _ -> []
    end
  end

  defp calculate_total_pages([]), do: 1
  defp calculate_total_pages(items), do: ceil(length(items) / @items_per_page)

  defp paginate(items, page) do
    Enum.slice(items, (page - 1) * @items_per_page, @items_per_page)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="flex flex-col items-center justify-center w-full">
      <%= if @user_data && @user_data.discord do %>
        <%= if length(@paginated_activities) > 0 do %>

          <div class="flex flex-col gap-4 w-full items-center min-h-[350px]">
            <%= for activity <- @paginated_activities do %>
              <.activity activity={activity} />
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
                aria-label={"Go to page #{page}"}
              ></button>
            <% end %>
          </div>
        <% else %>
          <div class="flex flex-col items-center justify-center min-h-[350px]">
            <p class="text-gray-400 italic text-sm">Not currently up to anything...</p>
          </div>
        <% end %>
      <% else %>
        <div class="flex flex-col items-center justify-center min-h-[350px]">
          <p class="text-gray-400 text-sm">Unable to get Discord data...</p>
        </div>
      <% end %>
    </div>
    """
  end

  attr :activity, :map, required: true
  def activity(assigns) do
    ~H"""
    <div :if={@activity.name == "Spotify"} class="w-full max-w-sm">
      <.spotify_activity activity={@activity} />
    </div>

    <div :if={@activity.name != "Spotify"} class="bg-gray-800/30 border border-gray-700/50 rounded-lg p-3 w-full max-w-sm">
       <div class="flex gap-3">
        <div class="relative flex-shrink-0 w-16 h-16">
          <img src={@activity.large_image} class="w-full h-full rounded shadow-md object-cover" />
          <img :if={@activity.small_image} src={@activity.small_image} class="absolute -bottom-1 -right-1 w-6 h-6 rounded-full border-2 border-[#1a1b1e] object-cover" />
        </div>
        <div class="flex flex-col min-w-0 flex-1 gap-0.5 justify-center">
          <span class="text-[10px] text-gray-400 font-bold uppercase tracking-wider">Playing <%= @activity.name %></span>
          <div :if={@activity.details} class="text-sm text-white font-bold truncate"><%= @activity.details %></div>
          <div :if={@activity.state} class="text-xs text-gray-300 truncate"><%= @activity.state %></div>
        </div>
      </div>
    </div>
    """
  end

  attr :activity, :map, required: true
  def spotify_activity(assigns) do
    ~H"""
    <div class="bg-gray-800/30 border border-[#1DB954]/20 rounded-lg p-3 w-full max-w-sm">
      <div class="flex gap-3">
        <div class="relative flex-shrink-0 w-16 h-16">
          <img src={@activity.large_image} class="w-full h-full rounded shadow-md object-cover" />
        </div>
        <div class="flex flex-col min-w-0 flex-1 gap-0.5 justify-center">
          <span class="text-[10px] text-gray-400 font-bold uppercase tracking-wider">Listening on Spotify</span>
          <span class="text-sm text-white font-bold truncate"><%= @activity.details %></span>
          <span class="text-xs text-gray-300 truncate">by <%= @activity.state %></span>
          <span class="text-xs text-gray-400 truncate text-[10px]">on <%= @activity.large_text %></span>
        </div>
      </div>
    </div>
    """
  end
end
