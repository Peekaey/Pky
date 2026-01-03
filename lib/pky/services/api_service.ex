  defmodule Pky.Services.ApiService do
  @moduledoc "
  Service module for external API Calls
  "
  alias Pky.Helpers.MioriParser, as: Parser
  require Logger


  @spec fetch_userdata_from_miori() :: {:ok, term()} | {:error, term()}
  def fetch_userdata_from_miori() do

    case Req.get("https://api.miori.dev/v1/user/181661376584876032/all?steamId=Peekaey",
    headers: [{"x-api-key", api_key()}]
    ) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, Parser.parse_user_data(body)}

      {:error, %{status: status}} ->
        Logger.error("Failed to fetch data from Miori API: #{inspect(status)}")
        {:error, {:unexpected_status, status}}

      {:error, exception} ->
        Logger.error("Error while fetching data from Miori API: #{inspect(exception)}")
        {:error, exception}
    end
  end

  defp api_key, do: Application.fetch_env!(:pky, :miori_api_key)

  end
