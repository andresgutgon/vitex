defmodule VitexTest do
  use ExUnit.Case, async: true

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
