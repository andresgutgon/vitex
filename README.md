[![CI](https://github.com/andresgutgon/vitex/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/andresgutgon/vitex/actions/workflows/ci.yml)

# Vitex

[ViteJS](http://vite.dev/) + [Phoenix](https://www.phoenixframework.org/) + [InertiaJS](https://github.com/inertiajs/inertia-phoenix) = ❤️

Vitex is a helper library that integrates Vite with Phoenix Framework, offering dev/prod asset handling and custom SSR support tailored for InertiaJS apps.

## 📚 Table of Contents

- [✅ Features](#-features)
- [🚀 Installation](#-installation)
- [Configure Vitex](#configure-vitex)
- [Add Vitex.HTML module](#add-vitexhtml-module)
- [Configuring ViteJS in your Phoenix app](#configuring-vitejs-in-your-phoenix-app)
- [Using ViteJS Inertia Adapter](#using-vitejs-inertia-adapter)

## ✅ Features

It makes working with Vite in Phoenix easier by:

1. Generating the correct asset tags in dev and prod modes `<.vitex_assets js={["./js/app.tsx"]} />`
2. Providing a custom SSR Inertia adapter for development (calling your local Vite server instead of running a NodeJS subprocess).

## 🚀 Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `vitex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vitex, "~> 0.1.0"}
  ]
end
```

## Configure Vitex

Add the following to your `lib/my_app/application.ex` file. Only `dev_mode` and `endpoint` are required. The rest are optional.

```elixir
# lib/my_app/application.ex
defmodule MyApp.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {
        Vitex,
        # If true it delegates assets to vite dev server. If false it uses generated vitejs manifest file.
        dev_mode: config_env() == :dev,
        # This is mandatory. Is used to read generated ViteJS manifest file.
        endpoint: MyAppWeb.Endpoint,

        # Optional: pass a custom manifest path. By default "priv/static/assets"
        manifest_path: "...",

        # Optional: pass a custom manifest name. By default "manifest"
        manifest_name: "...",

        # Optional: pass a custom vite host. By default it runs "http://localhost:5173"
        vite_host: "...",

        # Optional: this add code specific for your JS framework like React's refresh
        js_framework: "...", # :react, :vue, :svelte,

        # Optional: Host for you assets in production. Ex.: `assets.myapp.com`. By
        # default it assumes same site so it renders "/assets/app.38FTlhdd.js"
        assets_host: "...", # Used in production. In development assets are handled by Vite dev server

        # Optional. By default is already :nodejs. But in the future we could add :bun
        # or :deno runtime for rendering inertia SSR components
        runtime: :nodejs,
      }
    ]
  end
end
```

## Add Vitex.HTML module

Add this to your `MyAppWeb` module:

```elixir
# lib/my_app_web.ex
defmodule MyAppWeb do
    def html do
      quote do
        use Phoenix.Component

+       import Vitex.HTML
      end
    end
end
```

Once the HTML helper is added to your app you can use the assets helper

```elixir
# lib/my_app_web/components/layouts/root.html.heex
    <!DOCTYPE html>
    <html lang="en" class="[scrollbar-gutter:stable]">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={get_csrf_token()} />

+       <.vitex_assets js={["./js/app.tsx"]} />

      </head>
      <body class="bg-white">
        {@inner_content}
      </body>
    </html>
```

## Configuring ViteJS in your Phoenix app

You would need to have a ViteJS setup in your Phoenix app. You can follow the [ViteJS documentation](https://vitejs.dev/guide/) to set it up. Once you have ViteJS running, you can use the `vite` command to start the dev server.

```typescript
// assets/vite.config.ts
+ import vitexPlugin from "../deps/vitex/priv/vitejs/vitePlugin.js";

export default defineConfig(() => {
  return {
    plugins: [
      // ... other plugins like tailwind() or react()
+     vitexPlugin({ inertiaSSREndpoint: "./js/ssr.tsx" }),
    ],
  };
});
```

## Using ViteJS Inertia Adapter

Install inertia following the [InertiaJS documentation](https://github.com/inertiajs/inertia-phoenix?tab=readme-ov-file#installation). Once you have the Inertia's configuration use Vitex adapter for ViteJS

```elixir
# config/config.exs
config :inertia,
  ssr_adapter: Vitex.inertia_ssr_adapter(dev_mode: config_env() == :dev),
  # Optional pass a custom vite host if your vite server is running in another
  # port. By default it runs "http://localhost:5173"
  vite_host: "http://localhost:4242",
  # ...rest of configuration for Inertia
```
