defmodule Pky.Services.MioriApiService do
  require Logger
  alias Pky.Models.MioriUserData

  # https://github.com/Peekaey/Miori
  @spec fetch_miori_userdata() :: {:ok, MioriUserData.t()} | {:error, term()}
  def fetch_miori_userdata() do
    url = "https://api.miori.dev/v1/user/181661376584876032/all?steamId=Peekaey"
    make_request(url)
  end

  defp make_request(url) do
    case Req.get(url, headers: headers()) do

      {:ok, %{status: 200, body: body}} ->
        case MioriUserData.new(body) do
          {:ok, struct} ->
            {:ok, struct}

          {:error, changeset} ->
            Logger.error("Failed to parse Miori API response: #{inspect(changeset.errors)}")
            {:error, :parsing_error}
        end

      # HTTP Error
      {:ok, %{status: status}} ->
        Logger.error("Miori API returned error status: #{status} for URL: #{url}")
        {:error, {:http_error, status}}

      # Network Error
      {:error, exception} ->
        Logger.error("Network error fetching Miori data: #{inspect(exception)}")
        {:error, exception}
    end
  end

  defp headers do
    [{"x-api-key", Application.fetch_env!(:pky, :miori_api_key)}]
  end
end
