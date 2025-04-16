defmodule Vitex.Config do
  @moduledoc false
  defstruct(
    endpoint: nil,
    dev_mode: false,
    manifest_path: "priv/static/assets",
    manifest_name: "manifest",
    vite_host: Vitex.default_vite_host(),
    runtime: :nodejs,
    js_framework: nil,
    assets_host: nil,
    assets: %{js: [], css: []}
  )

  @type assets :: %{
          js: %{required(String.t()) => %{compiledFile: String.t(), entry: map()}},
          css: %{required(String.t()) => [String.t()]}
        }
  @type t :: %__MODULE__{
          vite_host: String.t(),
          manifest_path: String.t(),
          manifest_name: String.t(),
          assets: assets(),
          runtime: :nodejs | :bun,
          js_framework: :react | :vue | :svelte | nil,
          dev_mode: boolean(),
          endpoint: module(),
          assets_host: String.t() | nil
        }

  @type config_opt ::
          {:dev_mode, boolean()}
          | {:endpoint, module()}
          | {:vite_host, String.t()}
          | {:assets_host, String.t()}
          | {:runtime, :nodejs | :bun}
          | {:js_framework, :react | :vue | :svelte | nil}
          | {:manifest_path, String.t()}
          | {:manifest_name, String.t()}
          | {:assets, assets()}

  @spec build([config_opt]) :: t()
  def build(opts \\ []) do
    required_keys = [:dev_mode, :endpoint]

    missing =
      required_keys
      |> Enum.reject(fn key ->
        Keyword.has_key?(opts, key) and not is_nil(Keyword.get(opts, key))
      end)

    if missing != [] do
      raise ArgumentError,
            "Missing required config option(s): #{Enum.map_join(missing, ", ", &inspect/1)}"
    end

    struct(__MODULE__, opts)
  end
end
