defmodule PkyWeb.Live.Components.Widgets.WeatherWidget do
  @moduledoc """
  Component for displaying live weather data for Sydney city from OpenWeather
  """
  use PkyWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex items-center gap-3  border-gray-700/50 rounded-lg ">
      <%= case @weather_result do %>
        <% {:ok, weather} -> %>
          <span class="text-xs font-mono font-bold text-gray-400">
            {weather.temp}°C
          </span>

          <img
            src={"https://openweathermap.org/img/wn/#{weather.icon_code}@2x.png"}
            class="w-10 h-10 object-contain -mx-1"
            alt={weather.condition}
          />

          <span class="text-xs font-mono text-gray-400 capitalize whitespace-nowrap">
            {weather.description}
          </span>
        <% {:error, _reason} -> %>
          <div class="text-gray-500 text-xs italic">Weather unavailable</div>
        <% _loading -> %>
          <div class="animate-pulse text-gray-500 text-xs italic">Fetching weather...</div>
      <% end %>
    </div>
    """
  end
end
