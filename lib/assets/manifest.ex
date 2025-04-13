defmodule Vitex.Assets.Manifest do
  @moduledoc """
  Reads and resolves manifest.json files for asset management.
  Agnostic of bundler and adapter.

  Supports caching and runtime config merging.
  """

  alias Vitex.Assets.Config

  @default_manifest_name "vite_manifest.json"
  @default_manifest_path "priv/static/assets"
  @persistent_manifest_key :vitex_assets_manifest
  @persistent_opts_key :vitex_assets_opts

  @type manifest :: map()
  @type opts :: keyword()

  @spec read(opts()) :: manifest()
  def read(opts \\ []) do
    opts = Keyword.merge(Config.all(), opts)

    case :persistent_term.get(@persistent_manifest_key, nil) do
      nil ->
        manifest = load_manifest(opts)
        maybe_cache_manifest(manifest, opts)
        manifest

      manifest ->
        manifest
    end
  end

  @spec entry(manifest(), String.t()) :: map()
  def entry(manifest, path) do
    Map.get(manifest, path, %{})
  end

  @spec css_files(manifest(), String.t()) :: [String.t()]
  def css_files(manifest, path) do
    manifest
    |> entry(path)
    |> Map.get("css", [])
    |> List.wrap()
    |> Enum.map(&prepend_slash/1)
  end

  @spec js_file(manifest(), String.t()) :: String.t()
  def js_file(manifest, path) do
    manifest
    |> entry(path)
    |> Map.get("file")
    |> prepend_slash()
  end

  @spec clear_cache() :: :ok
  def clear_cache do
    :persistent_term.erase(@persistent_manifest_key)
    :persistent_term.erase(@persistent_opts_key)
    :ok
  end

  defp load_manifest(opts) do
    manifest_path = Keyword.get(opts, :manifest_path, @default_manifest_path)
    manifest_name = Keyword.get(opts, :manifest_name, @default_manifest_name)

    path = Path.join(manifest_path, manifest_name)

    case File.read(path) do
      {:ok, contents} ->
        Jason.decode!(contents)

      {:error, reason} ->
        raise RuntimeError,
              "Failed to read manifest file at #{path}: #{inspect(reason)}"
    end
  end

  defp maybe_cache_manifest(manifest, opts) do
    dev_mode = Keyword.get(opts, :dev_mode, false)

    unless dev_mode do
      :persistent_term.put(@persistent_manifest_key, manifest)
    end

    manifest
  end

  defp prepend_slash(nil), do: ""
  defp prepend_slash(path) when is_binary(path), do: "/" <> path
end
