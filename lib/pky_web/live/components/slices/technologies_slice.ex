defmodule PkyWeb.Live.Components.Slices.TechnologiesSlice do
  @moduledoc """

  """

  use PkyWeb, :live_component
  import PkyWeb.Live.Components.SvgComponents
  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 border-gray-700/50  text-white">
      <div class="flex flex-col items-center text-center rounded-lg pg-4 border-gray-700/50  bg-gray-800/30 border pb-2">
        <span class="block text-xs font-bold text-gray-400 mb-3 uppercase">Languages</span>
        <div class="flex flex-wrap gap-3">
          <a href="https://learn.microsoft.com/en-us/dotnet/csharp/">
            <.csharp_logo class="h-6" />
          </a>
          <a href="https://elixir-lang.org/">
            <.elixir_logo class="h-6" />
          </a>
          <a href="https://www.typescriptlang.org/">
            <.typescript_logo class="h-6" />
          </a>
          <a href="https://rust-lang.org/">
            <.rust_logo class="h-6" />
          </a>
        </div>
      </div>

      <div class="flex flex-col items-center text-center bg-gray-800/30 border-gray-700/50  rounded-lg border pg-4 pb-2 pl-2 pr-2">
        <span class="block text-xs font-bold text-gray-400 mb-3 uppercase">Stack</span>
        <div class="flex flex-wrap gap-3">
          <a href="https://dotnet.microsoft.com/en-us/">
            <.dotnet_logo class="h-7" />
          </a>
          <a href="https://www.phoenixframework.org/">
            <.phoenix_logo class="h-7" />
          </a>
          <a href="https://react.dev/">
            <.react_logo class="h-7" />
          </a>
          <%!-- <a href="https://nodejs.org/en"/>
          <.nodejs_logo class="h-7" />
          </a> --%>
          <a href="https://tailwindcss.com/">
            <.tailwind_logo class="h-7" />
          </a>
        </div>
      </div>

      <div class="flex flex-col items-center text-center md:col-span-2 border-gray-700/50 rounded-lg pg-4 bg-gray-800/30 border  pb-3">
        <span class="block text-xs font-bold text-gray-400 mb-3 uppercase ">
          Infrastructure & Ops
        </span>
        <div class="flex flex-wrap gap-3">
          <a href="https://www.linux.org/">
            <.linux_logo class="h-6" />
          </a>
          <a href="https://www.docker.com/">
            <.docker_logo class="h-6" />
          </a>
          <a href="https://k3s.io/">
            <.k3s_logo class="h-6" />
          </a>
          <a href="https://aws.amazon.com/">
            <.aws_logo class="h-6" />
          </a>
          <a href="https://www.microsoft.com/en-au/sql-server/">
            <.sql_server_logo class="h-6" />
          </a>
          <a href="https://www.postgresql.org/">
            <.postgresql_logo class="h-6" />
          </a>
          <a href="https://redis.io/">
            <.redis_logo class="h-6" />
          </a>
          <a href="https://www.rabbitmq.com/">
            <.rabbitmq_logo class="h-6" />
          </a>
        </div>
      </div>
    </div>
    """
  end
end
