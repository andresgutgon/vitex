defmodule Vitex.Inertia.SSR.DevAdapterTest do
  use ExUnit.Case, async: true

  alias Vitex.Inertia.SSR.{Config, DevAdapter}

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  test "successfully receives SSR response", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/ssr_render", fn conn ->
      Plug.Conn.resp(
        conn,
        200,
        Jason.encode!(%{"head" => "<title>SSR</title>", "body" => "<div>Content</div>"})
      )
    end)

    config = %Config{vite_host: "http://localhost:#{bypass.port}"}
    page = %{"component" => "Home", "props" => %{}, "url" => "/", "version" => nil}

    assert {:ok, %{"head" => _head, "body" => _body}} = DevAdapter.call(page, config)
  end

  test "returns error on invalid JSON response", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/ssr_render", fn conn ->
      Plug.Conn.resp(conn, 200, "not-json")
    end)

    config = %Config{vite_host: "http://localhost:#{bypass.port}"}
    page = %{"component" => "Home", "props" => %{}, "url" => "/", "version" => nil}

    assert {:error, "Invalid JSON response from Vite SSR"} = DevAdapter.call(page, config)
  end

  test "handles connection error gracefully", %{bypass: bypass} do
    Bypass.down(bypass)

    config = %Config{vite_host: "http://localhost:#{bypass.port}"}
    page = %{"component" => "Home", "props" => %{}, "url" => "/", "version" => nil}

    assert {:error, msg} = DevAdapter.call(page, config)
    assert msg =~ "Unable to connect to Vite dev server"
  end

  test "handles 500 with stack trace", %{bypass: bypass} do
    Bypass.expect(bypass, "POST", "/ssr_render", fn conn ->
      Plug.Conn.resp(conn, 500, Jason.encode!(%{"error" => %{"stack" => "stacktrace goes here"}}))
    end)

    config = %Config{vite_host: "http://localhost:#{bypass.port}"}
    page = %{"component" => "Home", "props" => %{}, "url" => "/", "version" => nil}

    assert {:error, "stacktrace goes here"} = DevAdapter.call(page, config)
  end
end
