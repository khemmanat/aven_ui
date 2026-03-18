defmodule AvenUITest do
  use ExUnit.Case
  doctest AvenUI

  test "version returns a string" do
    assert is_binary(AvenUI.version())
  end
end
