defmodule PkyWeb.IndexHTML do
  @moduledoc """
  This module contains pages rendered by IndexController.

  See the `index_html` directory for all templates available.
  """
  use PkyWeb, :html

  alias Pky.Models.MioriUserData

  @typedoc "Assigns for the index template"
  @type index_assigns :: %{
          :user_data => MioriUserData.t() | nil,
          optional(atom()) => any()
        }

  @doc """
  Renders the index page.

  ## Assigns
    * `:user_data` - User data from Miori API or nil
  """
  @spec index(index_assigns()) :: Phoenix.LiveView.Rendered.t()
  embed_templates "./*"
end

# TODO
# See if normal MVC files are still needed as we moved to LiveView
