defmodule PukeyTest do
  use ExUnit.Case
  require Pukey
  import Pukey

  @xml """
  <a>
  \t<b>2</b>
  \t<c>3</c>
  \t<c>4</c>
  </a>
  <d>2</d>
  """

  test "" do
    assert @xml =~ encode!(%{a: [%{b: 2, c: 3},  [c: 4]], d: 2})
    assert @xml =~ encode!([a: [b: 2, c: 3, c: 4], d: 2])
  end

  test "decode xml" do
    assert decode!(@xml) == [a: [b: "2", c: "3", c: "4"], d: "2"]
  end
end
