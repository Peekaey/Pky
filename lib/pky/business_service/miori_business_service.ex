defmodule Pky.BusinessService.MioriBusinessService do
  @moduledoc """
  Business Service module for handling Miori API related logic.
  """

  alias Pky.Services.MioriApiService
  alias Pky.Models.MioriUserData

  @spec get_miori_user_data() :: {:ok, MioriUserData.t()} | {:error, any()}
  def get_miori_user_data() do
    MioriApiService.fetch_miori_userdata()
  end

  @spec get_miori_anilist() :: {:ok, MioriUserData.t()} | {:error, any()}
  def get_miori_anilist() do
    MioriApiService.fetch_miori_anilist()
  end
end
