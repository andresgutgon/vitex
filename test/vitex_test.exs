defmodule VitexTest do
  use ExUnit.Case, async: true
  alias Vitex.ConfigStore

  describe "#start_link" do
    setup do
      # Clean up any previous agent if running
      Agent.stop(ConfigStore)
      :ok
    catch
      :exit, _ -> :ok
    end

    test "starts and initializes with valid config" do
      assert {:ok, _pid} =
               Vitex.start_link(
                 dev_mode: true,
                 endpoint: MyAppWeb.Endpoint,
                 js_framework: :react
               )

      config = ConfigStore.get()

      assert config.dev_mode == true
      assert config.endpoint == MyAppWeb.Endpoint
      assert config.js_framework == :react
    end

    test "raises when required keys are missing" do
      assert_raise ArgumentError, ~r/Missing required config option\(s\)/, fn ->
        Vitex.start_link([])
      end
    end
  end

  describe "#inertia_ssr_adapter/1" do
    test "returns DevAdapter when dev_mode is true" do
      adapter = Vitex.inertia_ssr_adapter(dev_mode: true)
      assert adapter == Vitex.Inertia.SSR.DevAdapter
    end

    test "returns NodeJS as default runtime" do
      adapter = Vitex.inertia_ssr_adapter(dev_mode: false)
      assert adapter == Inertia.SSR.Adapters.NodeJS
    end

    test "raises when runtime is :bun and dev_mode is false" do
      assert_raise RuntimeError, ~r/The Bun runtime is not implemented/, fn ->
        Vitex.inertia_ssr_adapter(dev_mode: false, runtime: :bun)
      end
    end
  end
end
