defmodule PkyWeb.Live.Components.Slices.TechnologiesSlice do
  @moduledoc """

  """

  use PkyWeb, :live_component
  import PkyWeb.Live.Components.SvgComponents
  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-white">
      <div class="rounded-lg pg-4  bg-gray-800/30 border border-[#1DB954]/20 pb-2 pl-2">
        <span class="block text-xs font-bold text-gray-400 mb-3 uppercase">Languages</span>
        <div class="flex flex-wrap gap-3">
          <.csharp_logo class="h-6" />
          <.elixir_logo class="h-6" />
          <.typescript_logo class="h-6" />
          <.rust_logo class="h-6" />
        </div>
      </div>

      <div class="bg-gray-800/30 border-[#1DB954]/20 rounded-lg border pg-4 pb-2 pl-2 pr-2">
        <span class="block text-xs font-bold text-gray-400 mb-3 uppercase">Stack</span>
        <div class="flex flex-wrap gap-3">
          <.dotnet_logo class="h-6" />
          <.phoenix_logo class="h-6" />
          <.react_logo class="h-6" />
          <.nodejs_logo class="h-6" />
          <.tailwind_logo class="h-6" />
        </div>
      </div>

      <div class="md:col-span-2 rounded-lg p-4 bg-gray-800/30 border border-[#1DB954]/20  ">
        <span class="block text-xs font-bold text-gray-400 mb-3 uppercase">Infrastructure & Ops</span>
        <div class="flex flex-wrap gap-3">
          <.linux_logo class="h-6" />
          <.docker_logo class="h-6" />
          <.aws_logo class="h-6" />
          <.sql_server_logo class="h-6" />
          <.postgresql_logo class="h-6" />
          <.redis_logo class="h-6" />
          <.rabbitmq_logo class="h-6" />
        </div>
      </div>
    </div>
    """
  end
end
