defmodule Pky.Services.UptimeApiService do
  @moduledoc """
  API Service responsible for querying sites/services to check for availability
  """

  @spec check_site(String.t()) :: {:ok, :up} | {:ok, :down} | {:error, any()}
  def check_site(url) do
    # 5s timeout
    case Req.get(url, receive_timeout: 5000) do

      {:ok, %{status: 200}} ->
        {:ok, :up}

      # Edge case for Plex - Unauthorized is still online/up
      {:ok, %{status: 401}} ->
        {:ok, :up}

      # Other HTTP Status
      {:ok, _response} ->
        {:ok, :down}

      # Network failure
      {:error, reason} ->
        {:error, reason}
    end
  end
end
