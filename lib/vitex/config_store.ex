defmodule Vitex.ConfigStore do
  @moduledoc false

  use Agent
  require Logger
  alias Vitex.{Config, Manifest}

  def start_link(_opts) do
    Agent.start_link(fn -> %Vitex.Config{} end, name: __MODULE__)
  end

  @spec init([Config.config_opt()]) :: Config.t()
  def init(opts \\ []) do
    config = Config.build(opts)
    assets = Manifest.load(config)
    config = %{config | assets: assets}
    Agent.update(__MODULE__, fn _ -> config end)
    config
  end

  @spec get_assets([String.t()]) :: %{js: [String.t()], css: [String.t()]}
  def get_assets(js_keys) do
    Agent.get(__MODULE__, fn %Vitex.Config{assets: %{js: js_entries, css: css_entries}} ->
      js_keys = js_keys || []

      {js_sources, missing_keys} = extract_js_sources(js_keys, js_entries)
      css_files = extract_css_files(js_keys, css_entries)

      maybe_log_missing_keys(missing_keys, js_entries)

      %{js: js_sources, css: css_files}
    end)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  defp extract_js_sources(keys, js_entries) do
    Enum.reduce(keys, {[], []}, fn key, {sources, missing} ->
      case Map.get(js_entries, key) do
        %{"compiledFile" => file} -> {[file | sources], missing}
        %{compiledFile: file} -> {[file | sources], missing}
        _ -> {sources, [key | missing]}
      end
    end)
    |> then(fn {sources, missing} ->
      {Enum.reverse(sources), Enum.reverse(missing)}
    end)
  end

  defp extract_css_files(keys, css_entries) do
    keys
    |> Enum.flat_map(&Map.get(css_entries, &1, []))
    |> Enum.uniq()
  end

  defp maybe_log_missing_keys([], _), do: :ok

  defp maybe_log_missing_keys(missing, js_entries) do
    Logger.warning("""
    [Vitex] Some JS entry points were not found in the manifest:
    #{Enum.join(missing, ", ")}

    Available keys: #{Enum.join(Map.keys(js_entries), ", ")}
    """)
  end
end
