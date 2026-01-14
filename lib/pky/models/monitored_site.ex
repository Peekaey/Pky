defmodule Pky.Models.MonitoredSite do
  @moduledoc """
  Defines a website that is being monitored
  Returns the URL and a "friendly" shorter slug
  """

  defstruct [:url, :label]

  @type t :: %__MODULE__{
    url: String.t(),
    label: String.t()
  }

  def new(url, label), do: %__MODULE__{url: url, label: label}
end
