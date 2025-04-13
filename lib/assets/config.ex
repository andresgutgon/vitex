defmodule Vitex.Assets.Config do
  @moduledoc """
  Handles global ViteJS assets configuration.
  Used by assets helpers and manifest readers.
  """

  @spec get(atom(), any()) :: any()
  def get(key, default \\ nil) do
    Keyword.get(all(), key, default)
  end

  @spec all() :: keyword()
  def all do
    Application.get_env(:vitex, :assets, [])
  end
end
