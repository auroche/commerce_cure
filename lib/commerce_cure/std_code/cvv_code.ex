defmodule CommerceCure.CvvCode do
  # Result of the Card Verification Value check
  # http://www.bbbonline.org/eExport/doc/MerchantGuide_cvv2.pdf
  # Check additional codes from cybersource website

  @messages %{
    "D"  =>  "CVV check flagged transaction as suspicious",
    "I"  =>  "CVV failed data validation check",
    "M"  =>  "CVV matches",
    "N"  =>  "CVV does not match",
    "P"  =>  "CVV not processed",
    "S"  =>  "CVV should have been present",
    "U"  =>  "CVV request unable to be processed by issuer",
    "X"  =>  "CVV check not supported for card"
  }

  @enforce_keys [:code, :message]
  defstruct     [:code, :message]

  def new(code) when is_binary(code) do
    if code = message(code) do
      {:ok, %__MODULE__{code: code, message: message(code)}}
    else
      {:error, :invalid_code}
    end
  end

  def new(code) when is_atom(code) do
    code
    |> Atom.to_string
    |> String.upcase
  end

  def message(code) do
    Map.get(@messages, code)
  end
end
