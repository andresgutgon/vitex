defmodule Inertia.Assets.Helper do
  @moduledoc """
  Phoenix component helper for rendering Inertia assets (JS and CSS).

  Dispatches to the configured adapter dynamically.
  Optionally includes preload tags.
  """

  use Phoenix.Component

  alias Inertia.Assets.{Config, Manifest, Resolver}

  @doc """
  Renders the required assets for Inertia pages.

  ## Assigns

    * `:js` - list of JS entry points (e.g. ["js/app.tsx"])
    * `:preload` - whether to include preload links (default: false)

  Example:

      <.inertia_assets js={["js/app.tsx"]} preload />
  """
  attr :js, :list, required: true
  attr :preload, :boolean, default: false

  def inertia_assets(assigns) do
    adapter = Config.adapter_module()
    config = Config.all()

    manifest = Manifest.read(config)
    assets = Resolver.resolve(manifest, assigns.js)

    preload_tags =
      if assigns.preload do
        preload_tags(assets)
      else
        []
      end

    [
      preload_tags,
      adapter.render_assets(assigns.js, config)
    ]
  end

  defp preload_tags(assets) do
    assigns = %{assets: assets}

    ~H"""
    <%= for css <- @assets.css do %>
      <link rel="preload" as="style" href={css} />
    <% end %>

    <%= for js <- @assets.js do %>
      <link rel="modulepreload" href={js} />
    <% end %>
    """
  end
end

