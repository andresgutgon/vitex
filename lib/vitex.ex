defmodule Vitex do
  @moduledoc """
  The ViteJS integration for Phoenix Framework and InertiaJS.
  It provides a set of helpers to use ViteJS in your Phoenix application.
  """

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
