import Config

# Load .env at runtime
if File.exists?(".env") do
  ".env"
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.reject(&(&1 == "" || String.trim(&1) |> String.starts_with?("#")))
  |> Enum.each(fn line ->
    case String.split(line, "=", parts: 2) do
      [key, value] ->
        value =
          value
          |> String.trim()
          |> String.trim_leading(~s("))
          |> String.trim_trailing(~s("))
          |> String.trim_leading(~s('))
          |> String.trim_trailing(~s('))

        System.put_env(key, value)

      _ ->
        :ignore
    end
  end)
end

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/pky start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :pky, PkyWeb.Endpoint, server: true
end

# Require MIORI_API_KEY for all environments
miori_api_key =
  System.get_env("MIORI_API_KEY") ||
    raise """
    environment variable MIORI_API_KEY is missing.
    """
openweather_api_key =
  System.get_env("OPENWEATHER_API_KEY") ||
  raise """
  environment varriable OPENWEATHER_API_KEY is missing
  """

config :pky, miori_api_key: miori_api_key , openweather_api_key: openweather_api_key

if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """


  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :pky, PkyWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Bind to all interfaces
      ip: {0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
