defmodule Pky.BusinessService.ApiBusinessService do
  @moduledoc """
  Business Service module for handling API related business logic.
  """

  alias Pky.Services.ApiService

  @type user_data :: map()

  @spec get_user_data() :: {:ok, user_data} | {:error, any()}
  def get_user_data() do
    case ApiService.fetch_userdata_from_miori() do
      {:ok, data} ->
        {:ok, data}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
