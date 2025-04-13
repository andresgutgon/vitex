defmodule VitexTest do
  use ExUnit.Case
  doctest Vitex

  test "greets the world" do
    assert Vitex.hello() == :world
  end
end
