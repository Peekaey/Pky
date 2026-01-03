defmodule PkyWeb.IndexController do
  use PkyWeb, :controller

  alias Pky.BusinessService.ApiBusinessService

  require Logger

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    case ApiBusinessService.get_user_data() do
      {:ok, %{discord: _, anilist: _, spotify: _, steam: _, osu: _} = user_data} ->
        render(conn, :index, user_data: user_data)

      {:error, reason} ->
        Logger.error("Failed to fetch user data: #{inspect(reason)}")
        render(conn, :index, user_data: nil)
    end
  end
end
