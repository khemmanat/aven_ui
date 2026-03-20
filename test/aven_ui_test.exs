defmodule AvenUITest do
  use ExUnit.Case

  test "version is a string" do
    assert is_binary(AvenUI.version())
  end

  test "components list is not empty" do
    assert length(AvenUI.components()) > 0
  end
end
