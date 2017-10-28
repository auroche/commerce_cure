defmodule CommerceCure.ResponseTest do
  use ExUnit.Case
  use CommerceCure.Response

  def process_error(_) do
    {:ok, nil}
  end
end

defmodule CommerceCureTest do
  use ExUnit.Case
  use CommerceCure, otp_app: :commerce_cure
  alias CommerceCureTest, as: Me
  alias CommerceCure.ResponseTest, as: Response
  alias CommerceCure.PaymentCard

  plug Tesla.Middleware.JSON

  test "configs" do
    assert Me.config() == Application.get_env(:commerce_cure, __MODULE__)
  end

  test "fail" do
    # case :ok, :error
    amount = Money.new(1000, :CAD)
    # case :ok, :error
    {:ok, cc} = PaymentCard.new(%{
      number: "4242424242424242",
      name: "Jim Raynor",
      expiry_date: "07/19",
      verification_value: "123"
    })

    request = CommerceCure.purchase(amount, cc)
    http_response = Me.send(request)
    response = Response.new!(http_response)
    assert response.succeed?
  end
end
