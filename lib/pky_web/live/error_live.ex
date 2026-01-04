defmodule PkyWeb.ErrorLive do
  @moduledoc """
  LiveView for handling error pages (404, 500, etc.)
  """
  use PkyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Error")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="text-center">
      <h1 class="text-4xl font-bold">Page Not Found</h1>
      <p class="mt-4">Sorry, the page you are looking for does not exist.</p>
      <.link navigate={~p"/"} class="btn btn-primary mt-6">
        Go Home
      </.link>
    </div>
    """
  end
end
