defmodule Vitex.HTML do
  require Logger

  @moduledoc """
  Phoenix component helper for rendering Vite assets (JS and CSS).

  Optionally includes preload tags.
  """

  use Phoenix.Component
  import Phoenix.HTML, only: [raw: 1]
  alias Vitex.ConfigStore, as: Config

  @doc """
  Renders the required assets for ViteJS assets. Phoenix pages.

  ## Assigns

    * `:js` - list of JS entry points (e.g. ["js/app.tsx"])
    * `:preload` - whether to include preload links (default: false)

  Example:

      <.vitex_assets js={["js/app.tsx"]} preload />
  """
  attr(:js, :list, required: true)
  attr(:preload, :boolean, default: false)

  def vitex_assets(assigns) do
    config = Config.get()

    assets =
      if config.dev_mode do
        %{js: assigns.js || [], css: []}
      else
        Config.get_assets(assigns.js || [])
      end

    assigns =
      assigns
      |> assign_new(:preload, fn -> false end)
      |> assign(:assets, assets)
      |> assign(:dev_mode, config.dev_mode)
      |> assign(:js_framework, config.js_framework)
      |> assign(:asset_host, config.assets_host)
      |> assign(:vite_host, config.vite_host)

    ~H"""
    <%= if @preload and not @dev_mode do %>
      <%= preload_tags(@assets, @asset_host) %>
    <% end %>

    <%= if @dev_mode do %>
      <%= dev_assets(@assets, @vite_host, @js_framework) %>
    <% else %>
      <%= prod_assets(@assets, @asset_host) %>
    <% end %>
    """
  end

  defp dev_assets(assets, vite_host, js_framework) do
    assigns = %{assets: assets, vite_host: vite_host, js_framework: js_framework}

    ~H"""
    <%= if @js_framework == :react do %>
      <%= react_refresh(@vite_host) %>
    <% end %>
    <script type="module" src={"#{@vite_host}/@vite/client"}></script>
    <%= for js <- @assets.js do %>
      <script type="module" src={"#{@vite_host}/" <> js}></script>
    <% end %>
    """
  end

  defp prod_assets(assets, asset_host) do
    assigns = %{assets: assets, asset_host: asset_host}

    ~H"""
    <%= for css <- @assets.css do %>
      <link rel="stylesheet" phx-track-static href={asset_url(@asset_host, css)} />
    <% end %>

    <%= for js <- @assets.js do %>
      <script type="module" crossorigin defer phx-track-static src={asset_url(@asset_host, js)}></script>
    <% end %>
    """
  end

  defp preload_tags(assets, asset_host) do
    assigns = %{assets: assets, asset_host: asset_host}

    ~H"""
    <%= for css <- @assets.css do %>
      <link rel="preload" as="style" href={asset_url(@asset_host, css)} />
    <% end %>

    <%= for js <- @assets.js do %>
      <link rel="modulepreload" href={asset_url(@asset_host, js)} />
    <% end %>
    """
  end

  defp react_refresh(vite_host) do
    raw("""
    <script type="module">
      import RefreshRuntime from "#{vite_host}/@react-refresh"
      RefreshRuntime.injectIntoGlobalHook(window)
      window.$RefreshReg$ = () => {}
      window.$RefreshSig$ = () => (type) => type
      window.__vite_plugin_react_preamble_installed__ = true
    </script>
    """)
  end

  defp asset_url(nil, path), do: "/" <> path
  defp asset_url(host, path), do: host <> "/" <> path
end
