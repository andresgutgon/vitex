defmodule Vitex.Manifest do
  @moduledoc """
  Loads and processes the Vite manifest.
  Filters entries with isEntry: true and prepares structured JS and CSS maps.
  """

  require Logger

  @spec load(Vitex.Config.t()) :: Vitex.Config.assets()
  def load(%Vitex.Config{dev_mode: true}) do
    %{js: %{}, css: %{}}
  end

  @spec load(Vitex.Config.t()) :: Vitex.Config.assets()
  def load(%Vitex.Config{
        manifest_path: relative_path,
        manifest_name: name,
        endpoint: endpoint
      }) do
    otp_app = endpoint.config(:otp_app)

    manifest_path =
      otp_app
      |> Application.app_dir(relative_path)
      |> Path.join("#{name}.json")

    if File.exists?(manifest_path) do
      manifest_path
      |> File.read!()
      |> Jason.decode!()
      |> process_manifest()
    else
      Logger.warning("""
      Vitex: Manifest not found at #{manifest_path}. Returning empty assets.
      Check your build step or ensure `mix phx.digest` ran correctly.
      """)

      %{js: %{}, css: %{}}
    end
  end

  defp process_manifest(manifest) do
    entries =
      manifest
      |> Enum.filter(fn {_key, entry} -> Map.get(entry, "isEntry", false) end)

    js_map =
      entries
      |> Enum.into(%{}, fn {key, entry} ->
        {
          key,
          %{
            compiledFile: entry["file"]
          }
        }
      end)

    css_map =
      entries
      |> Enum.reduce(%{}, fn {key, entry}, acc ->
        css_files = Map.get(entry, "css", []) |> Enum.uniq()
        Map.put(acc, key, css_files)
      end)

    %{js: js_map, css: css_map}
  end
end
