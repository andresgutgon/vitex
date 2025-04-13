defmodule Inertia.Assets.Config do
  @moduledoc """
  Handles global Inertia assets configuration.
  Used by assets helpers and manifest readers.
  """

  @spec adapter_module() :: module()
  def adapter_module do
    case get(:adapter) |> String.downcase() do
      "vitejs" ->
        Inertia.SSR.Adapters.ViteJS

      nil ->
        Inertia.SSR.Adapters.NodeJS

      other ->
        raise ArgumentError,
              "Unknown Inertia assets adapter: #{inspect(other)}. " <>
                "Check your :inertia, :assets config."
    end
  end

  @spec get(atom(), any()) :: any()
  def get(key, default \\ nil) do
    Keyword.get(all(), key, default)
  end

  @spec all() :: keyword()
  def all do
    Application.get_env(:inertia, :assets, [])
  end
end
