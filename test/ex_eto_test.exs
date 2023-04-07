defmodule ExEToTest do
  use ExUnit.Case
  doctest ExETo

  test "greets the world" do
    assert ExETo.hello() == :world
  end
end
