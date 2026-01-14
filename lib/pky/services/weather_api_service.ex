defmodule Pky.Services.WeatherApiService do
  @moduledoc """
  API Service responsible for getting weather data from OpenWeather
  """
  alias Pky.Models.WeatherData


  @spec fetch_sydney_weather() :: {:ok, WeatherData.t()} | {:error, String.t() | Ecto.Changeset.t()}
  def fetch_sydney_weather() do
    url = "https://api.openweathermap.org/data/2.5/weather?id=2147714&appid=#{openweather_api_key()}&units=metric"

    case Req.get(url) do

      {:ok, %{status: 200, body: body}} ->
        WeatherData.new(body)

      # HTTP Status Errors
      {:ok, %{status: status}} ->
        {:error, "Weather API returned status: #{status}"}

      # Network/Connection Error
      {:error, _reason} ->
        {:error, "Weather service unreachable"}
    end
  end

  defp openweather_api_key, do: Application.fetch_env!(:pky, :openweather_api_key)
end
