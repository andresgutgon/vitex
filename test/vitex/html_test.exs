defmodule Vitex.HTMLTest do
  require Logger

  use ExUnit.Case, async: true
  use Phoenix.Component

  import ExUnit.CaptureLog
  import Phoenix.LiveViewTest

  alias Vitex.ConfigStore
  alias Vitex.HTML

  setup do
    start_supervised!(ConfigStore)
    :ok
  end

  describe "dev mode" do
    setup context do
      base_config = [
        endpoint: MyAppWeb.Endpoint,
        dev_mode: true,
        js_framework: :react
      ]

      ConfigStore.init(Keyword.merge(base_config, Map.to_list(context)))

      :ok
    end

    test "renders script tags for dev mode" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"])

      assert html =~ ~s(<script type="module" src="http://localhost:5173/@vite/client"></script>)
      assert html =~ ~s(<script type="module" src="http://localhost:5173/js/app.tsx"></script>)
      assert html =~ ~s(<script type="module">)
      assert html =~ ~s(import RefreshRuntime from "http://localhost:5173/@react-refresh")
      assert html =~ "RefreshRuntime.injectIntoGlobalHook(window)"
      assert html =~ "window.$RefreshReg$ = () => {}"
      assert html =~ "window.$RefreshSig$ = () => (type) => type"
      assert html =~ "window.__vite_plugin_react_preamble_installed__ = true"
      assert html =~ ~s(</script>)
    end

    @tag vite_host: "http://localhost:4269"
    test "renders script tags for dev mode with custom vite_host" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"])

      assert html =~ ~s(<script type="module" src="http://localhost:4269/@vite/client"></script>)

      assert html =~ ~s(<script type="module" src="http://localhost:4269/js/app.tsx"></script>)
      assert html =~ ~s(import RefreshRuntime from "http://localhost:4269/@react-refresh")
    end
  end

  describe "prod mode with assets_host" do
    setup do
      ConfigStore.init(
        dev_mode: false,
        endpoint: MyAppWeb.Endpoint,
        assets_host: "https://cdn.example.com",
        vite_host: "http://localhost:5173"
      )

      :ok
    end

    test "renders single JS and CSS asset" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"])

      assert html =~
               ~s(<link rel="stylesheet" phx-track-static href="https://cdn.example.com/assets/app.CC0PCmj2.css">)

      assert html =~
               ~s(<script type="module" crossorigin defer phx-track-static src="https://cdn.example.com/assets/app.BjbglPmr.js"></script>)
    end

    test "renders multiple JS and their CSS" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx", "js/other.tsx"])

      assert html =~
               ~s(<link rel="stylesheet" phx-track-static href="https://cdn.example.com/assets/app.CC0PCmj2.css">)

      assert html =~
               ~s(<script type="module" crossorigin defer phx-track-static src="https://cdn.example.com/assets/app.BjbglPmr.js"></script>)

      assert html =~
               ~s(<script type="module" crossorigin defer phx-track-static src="https://cdn.example.com/assets/other.BjbglPmr.js"></script>)
    end

    test "renders preload tags when preload is true" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"], preload: true)

      assert html =~
               ~s(<link rel="preload" as="style" href=\"https://cdn.example.com/assets/app.CC0PCmj2.css\">)

      assert html =~
               ~s(<link rel="modulepreload" href=\"https://cdn.example.com/assets/app.BjbglPmr.js\">)
    end

    test "does not render preload tags when preload is false" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"], preload: false)

      refute html =~ ~s(rel="preload")
      refute html =~ ~s(rel="modulepreload")
    end

    test "handles entries without CSS" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/other.tsx"])

      refute html =~ ~s(rel="stylesheet")

      assert html =~
               ~s(<script type="module" crossorigin defer phx-track-static src="https://cdn.example.com/assets/other.BjbglPmr.js"></script>)
    end
  end

  describe "prod mode without assets_host (relative paths)" do
    setup do
      ConfigStore.init(
        endpoint: MyAppWeb.Endpoint,
        dev_mode: false,
        assets_host: nil
      )

      :ok
    end

    test "renders single JS and CSS asset with relative paths" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"])

      assert html =~ ~s(href="/assets/app.CC0PCmj2.css")
      assert html =~ ~s(src="/assets/app.BjbglPmr.js")
    end

    test "renders multiple JS and CSS with relative paths" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx", "js/other.tsx"])

      assert html =~ ~s(href="/assets/app.CC0PCmj2.css")
      assert html =~ ~s(src="/assets/app.BjbglPmr.js")
      assert html =~ ~s(src="/assets/other.BjbglPmr.js")
    end

    test "renders preload tags with relative paths" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"], preload: true)

      assert html =~ ~s(<link rel="preload" as="style" href=\"/assets/app.CC0PCmj2.css\">)
      assert html =~ ~s(<link rel="modulepreload" href=\"/assets/app.BjbglPmr.js\">)
    end
  end

  describe "with missing JS entries" do
    setup do
      ConfigStore.init(
        endpoint: MyAppWeb.Endpoint,
        dev_mode: false
      )

      :ok
    end

    test "warns if JS entry is missing" do
      log =
        capture_log(fn ->
          render_component(&HTML.vitex_assets/1, js: ["js/missing.tsx"])
        end)

      assert log =~ "[Vitex] Some JS entry points were not found in the manifest:"
      assert log =~ "js/missing.tsx"
      assert log =~ "Available keys: js/app.tsx"
    end

    test "warns if some entries are missing and some exist" do
      log =
        capture_log(fn ->
          render_component(&HTML.vitex_assets/1, js: ["js/app.tsx", "js/unknown.tsx"])
        end)

      assert log =~ "[Vitex] Some JS entry points were not found in the manifest:"
      assert log =~ "js/unknown.tsx"
      assert log =~ "Available keys: js/app.tsx"
    end
  end

  describe "with custom manifest path" do
    setup do
      ConfigStore.init(
        endpoint: MyAppWeb.Endpoint,
        dev_mode: false,
        manifest_path: "priv/static/assets/custom-path"
      )

      :ok
    end

    test "render assets" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"])

      assert html =~ ~s(href="/assets/custom-manifest-path.CC0PCmj2.css")
      assert html =~ ~s(src="/assets/custom-manifest-path.BjbglPmr.js")
    end
  end

  describe "with custom manifest name" do
    setup do
      ConfigStore.init(
        endpoint: MyAppWeb.Endpoint,
        dev_mode: false,
        manifest_name: "custom-manifest-name"
      )

      :ok
    end

    test "render assets" do
      html = render_component(&HTML.vitex_assets/1, js: ["js/app.tsx"])

      assert html =~ ~s(href="/assets/custom-manifest-name.CC0PCmj2.css")
      assert html =~ ~s(src="/assets/custom-manifest-name.BjbglPmr.js")
    end
  end
end
