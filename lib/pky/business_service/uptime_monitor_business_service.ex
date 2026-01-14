defmodule Pky.BusinessService.UptimeMonitorBusinessService do
  @moduledoc """
  Coordinates checking sites. It takes a MonitoredSite struct,
  asks the API service to check it, and returns the combined result.
  """

  alias Pky.Services.UptimeApiService
  alias Pky.Models.MonitoredSite

  # Return type for UI to consume
  @type check_result :: {MonitoredSite.t(), :up} | {MonitoredSite.t(), :down}

  @spec check_site(MonitoredSite.t()) :: check_result()
  def check_site(%MonitoredSite{} = site) do
    # API layer returns {:ok, :up/down} or {:error, reason})
    status =
      case UptimeApiService.check_site(site.url) do
        {:ok, :up} -> :up
        {:ok, :down} -> :down
        {:error, _reason} -> :down # DNS/Timeout as Down
      end

    # Return the original site struct paired with its status
    {site, status}
  end
end
