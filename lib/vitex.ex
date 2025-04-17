defmodule Vitex do
  alias Vitex.{Config, ConfigStore}

  @moduledoc """
  The ViteJS integration for Phoenix Framework and InertiaJS.

  This module must be supervised with configuration passed at runtime:

      children = [
        {Vitex, dev_mode: true, endpoint: MyAppWeb.Endpoint}
      ]

  """

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @spec start_link([Config.config_opt()]) :: {:ok, pid()} | {:error, term()}
  def start_link(opts) do
    ConfigStore.start_link([])
    init(opts)
    {:ok, self()}
  end

  @spec init([Config.config_opt()]) :: Config.t()
  def init(opts \\ []) do
    ConfigStore.init(opts)
  end

  def default_vite_host, do: "http://localhost:5173"

  @spec inertia_ssr_adapter([
          {:dev_mode, boolean()},
          {:runtime, :nodejs | :bun}
        ]) :: module()
  def inertia_ssr_adapter(opts \\ []) do
    dev_mode = Keyword.fetch!(opts, :dev_mode)
    runtime = Keyword.get(opts, :runtime, :nodejs)

    cond do
      dev_mode ->
        Vitex.Inertia.SSR.DevAdapter

      runtime == :bun ->
        raise """
        The Bun runtime is not implemented.

        🚧 This is left here as an inspiration point.
        👉 Contributions are welcome!
        """

      true ->
        Inertia.SSR.Adapters.NodeJS
    end
  end
end
