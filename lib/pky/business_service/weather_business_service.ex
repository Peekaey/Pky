defmodule Pky.BusinessService.WeatherBusinessService do
  @moduledoc """
  Responsible for OpenWeather related logic
  """
  alias Pky.Services.WeatherApiService
  alias Pky.Models.WeatherData

  @spec fetch_sydney_weather :: {:ok, WeatherData.t()} | {:error, String.t()}
  def fetch_sydney_weather() do
      WeatherApiService.fetch_sydney_weather()
  end
end
