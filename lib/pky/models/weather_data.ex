defmodule Pky.Models.WeatherData do
  @moduledoc """
  Defines a WeatherData model containing various essential weather data about a location
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:temp, :humidity, :description, :condition, :icon_code]}

  embedded_schema do
    field :temp, :integer
    field :humidity, :integer
    field :description, :string
    field :condition, :string
    field :icon_code, :string
  end

  @type t :: %__MODULE__{}

  @doc """
  Parses the OpenWeatherMap API response.
  Returns {:ok, %Weather{}} or {:error, changeset}
  """
  def new(api_response) do
    # Extract the nested data safely
    weather_list_item = List.first(api_response["weather"]) || %{}

    # Flatten it into a map that matches schema keys
    params = %{
      "temp" => round_val(api_response["main"]["temp"]),
      "humidity" => round_val(api_response["main"]["humidity"]),
      "description" => weather_list_item["description"],
      "condition" => weather_list_item["main"],
      "icon_code" => weather_list_item["icon"]
    }

    # Cast and Validate
    %__MODULE__{}
    |> cast(params, [:temp, :humidity, :description, :condition, :icon_code])
    |> validate_required([:temp, :condition])
    |> apply_action(:insert) # Returns {:ok, struct} or {:error, changeset}
  end

  defp round_val(val) when is_number(val), do: round(val)
  defp round_val(_), do: nil
end
