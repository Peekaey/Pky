defmodule PkyWeb.Live.Components.UptimeWidget do
  @moduledoc """
  Component to display real-time service uptime status.
  """
  use PkyWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full flex flex-col items-center">
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 max-w-2xl">
        <%= for {site, status} <- @results do %>
          <div class="bg-gray-800/30 border border-gray-700/50 rounded-lg p-3 flex items-center justify-between gap-4 transition-all hover:bg-gray-800/50">
            <div class="flex items-center gap-3 flex-shrink-0">
              <span class="relative flex h-2 w-2">
                <span class={[
                  "animate-ping absolute inline-flex h-full w-full rounded-full opacity-75",
                  pulse_color(status)
                ]}>
                </span>
                <span class={["relative inline-flex rounded-full h-2 w-2", dot_color(status)]}></span>
              </span>

              <div class="flex flex-col min-w-0">
                <span class="text-xs font-bold text-white truncate">
                  {site.label}
                </span>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp pulse_color(:up), do: "bg-green-400"
  defp pulse_color(_), do: "bg-red-400"

  defp dot_color(:up), do: "bg-green-500"
  defp dot_color(_), do: "bg-red-500"
end
