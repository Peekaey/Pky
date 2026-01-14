defmodule PkyWeb.IndexController do
  use PkyWeb, :controller

  alias Pky.BusinessService.MioriBusinessService
  alias Pky.Models.MioriUserData

  require Logger

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do

    case MioriBusinessService.get_miori_user_data() do
      {:ok, %MioriUserData{} = user_data} ->
        render(conn, :index, user_data: user_data)

      {:error, reason} ->
        Logger.error("Failed to fetch user data: #{inspect(reason)}")

        # Flash message if site critically fails
        conn
        |> put_flash(:error, "Unable to load profile data.")
        |> render(:index, user_data: nil)
    end
  end
end
