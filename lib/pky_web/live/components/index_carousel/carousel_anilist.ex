defmodule PkyWeb.Live.Components.IndexCarousel.CarouselAnilist do
  @moduledoc """
  Displays Anilist user activities
  """

  use PkyWeb, :live_component

  @items_per_page 3

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

  defp calculate_total_pages([]), do: 1
  defp calculate_total_pages(items), do: ceil(length(items) / @items_per_page)

  defp paginate(items, page) do
    Enum.slice(items, (page - 1) * @items_per_page, @items_per_page)
  end

    defp get_activities(user_data) do
    case user_data do
      %{anilist: %{activities: activities}} when is_list(activities) ->
        # Filter out MESSAGE type activities > Leaving only MANGA and ANIME profile updates
        Enum.filter(activities, fn activity -> activity.type != "MESSAGE" end)

      _ ->
        []
    end
  end

  @impl true
def render(assigns) do
  ~H"""
  <div id={@id} class="flex flex-col items-center justify-center w-full">
    <%= if @user_data && @user_data.anilist do %>
      <%= if length(@paginated_activities) > 0 do %>
        <div class="flex flex-col gap-4 w-full items-center justify-center min-h-[350px]">
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
            >
            </button>
          <% end %>
        </div>
      <% else %>
        <div class="flex flex-col items-center justify-center min-h-[350px]">
          <p class="text-gray-400 italic text-sm">No recent activity...</p>
        </div>
      <% end %>
    <% else %>
      <div class="flex flex-col items-center justify-center min-h-[350px]">
        <p class="text-gray-400 text-sm">Unable to get Anilist data...</p>
      </div>
    <% end %>
  </div>
  """
end

  attr :activity, :map, required: true

  def activity(assigns) do
    ~H"""
    <a
      href={@activity.url}
      target="_blank"
      rel="noopener noreferrer"
      class="block bg-gray-800/30 border border-gray-700/50 rounded-lg p-3 w-full max-w-sm transition-all hover:bg-gray-800/50 hover:border-blue-500/30 group"
    >
      <div class="flex gap-3 items-center">
        <div class="relative flex-shrink-0 w-16 h-16">
          <img
            src={@activity.media.cover_image_url}
            class="w-full h-full rounded shadow-md object-cover"
            alt={@activity.media.title_english || @activity.media.title_romaji}
          />
        </div>

        <div class="flex flex-col min-w-0 flex-1 h-16 justify-between text-center items-center">
          <span class="text-[10px] text-gray-400 font-bold uppercase tracking-wider group-hover:text-blue-400 transition-colors truncate w-full">
            {format_status(@activity.status)}
          </span>

          <div class="flex flex-col min-w-0 w-full leading-tight">
            <div :if={@activity.progress} class="text-[10px] font-mono uppercase">
              <span class="text-gray-500">{@activity.progress}</span>
              <span class="text-gray-500 lowercase">of</span>
            </div>

            <div class="text-sm text-white font-bold truncate">
              {@activity.media.title_english || @activity.media.title_romaji}
            </div>
          </div>

          <div class="flex items-center justify-center gap-1 text-[10px] text-gray-500 font-mono mt-1">
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
            <span>{format_time_ago(@activity.created_at_utc)}</span>
          </div>
        </div>
      </div>
    </a>
    """
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

  defp format_status(status) do
    case status do
      "watched episode" -> "Watched Episode"
      "read chapter" -> "Read Chapter"
      "reread chapter" -> "Reread Chapter"
      "completed" -> "Completed"
      "plans to watch" -> "Planning to Watch"
      "plans to read" -> "Planning to Read"
      _ -> String.capitalize(status || "Activity")
    end
  end
end
