defmodule PkyWeb.Live.Components.LoadingComponent do
  @moduledoc """
  A full-page loading component displayed while data is being fetched.
  """
  use Phoenix.Component
  use Phoenix.VerifiedRoutes,
    endpoint: PkyWeb.Endpoint,
    router: PkyWeb.Router,
    statics: PkyWeb.static_paths()

  def loading_screen(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-gray-900 flex flex-col items-center justify-center z-50">
      <div class="relative">
        <%!-- <div class="w-16 h-16 border-4 border-gray-700 border-t-blue-500 rounded-full animate-spin"></div> --%>
            <img src={~p"/images/gifs/image01.gif"} alt="Loading..." class="mx-auto max-w-xl" />
      </div>

      <h2 class="mt-8 text-2xl font-semibold text-white">Loading</h2>
      <p class="mt-2 text-gray-400">Please wait...</p>

      <div class="flex space-x-2">
        <%!-- <div class="w-2 h-2 bg-blue-500 rounded-full animate-bounce"></div>
        <div class="w-2 h-2 bg-blue-500 rounded-full animate-bounce [animation-delay:150ms]"></div>
        <div class="w-2 h-2 bg-blue-500 rounded-full animate-bounce [animation-delay:300ms]"></div> --%>
      </div>
    </div>
    <%!-- <div>
      <img src={~p"/images/luckystar.gif"} alt="Loading..." class="mx-auto" />
    </div> --%>
    """
  end
end
