defmodule CommerceCure.Http.StatusTest do
  use ExUnit.Case
  alias CommerceCure.Http.Status
  doctest Status

  test "200" do
    assert Status.code(:ok) == 200
    assert Status.reason_phrase(200) == "OK"
  end

end
