defmodule CommerceCure.PaymentCardNumber do
  @companies [
    visa:               ~r/^4\d{12}(\d{3})?(\d{3})?$/,
    mastercard:             ~r/^(5[1-5]\d{4}|677189|222[1-9]\d{2}|22[3-9]\d{3}|2[3-6]\d{4}|27[01]\d{3}|2720\d{2})\d{10}$/,
    discover:           ~r/^(6011|65\d{2}|64[4-9]\d)\d{12}|(62\d{14})$/,
    american_express:   ~r/^3[47]\d{13}$/,
    diners_club:        ~r/^3(0[0-5]|[68]\d)\d{11}$/,
    jcb:                ~r/^35(28|29|[3-8]\d)\d{12}$/,
    switch:             ~r/^6759\d{12}(\d{2,3})?$/,
    solo:               ~r/^6767\d{12}(\d{2,3})?$/,
    dankort:            ~r/^5019\d{12}$/,
    maestro:            ~r/^(5[06-8]|6\d)\d{10,17}$/,
    forbrugsforeningen: ~r/^600722\d{10}$/,
    laser:              ~r/^(6304|6706|6709|6771(?!89))\d{8}(\d{4}|\d{6,7})?$/
  ]

  @type brand :: :visa | :master | :discover | :american_express | :diners_club |
                 :jcb | :switch | :solo | :dankort | :maestro | :forbrugsforeningen |
                 :laser | :unknown_brand
  @type t :: %__MODULE__{brand: brand, number: String.t}

  @enforce_keys [:brand, :number]
  defstruct     [:brand, :number]

  @doc """
  iex> PaymentCardNumber.new("4242424242424242")
  {:ok, %PaymentCardNumber{brand: :visa, number: "4242424242424242"}}
  iex> PaymentCardNumber.new(4242424242424242)
  {:ok, %PaymentCardNumber{brand: :visa, number: "4242424242424242"}}
  iex> PaymentCardNumber.new(4242424242424241)
  {:error, :failed_checksum}
  iex> PaymentCardNumber.new("a242424242424242")
  {:error, :failed_checksum}
  """
  @spec new(String.t | integer) :: t
  def new(numbers) do
    with :ok <- validate_length(numbers),
         :ok <- validate_luhn(numbers)
    do
      numbers = if is_integer(numbers),
        do: Integer.to_string(numbers),
      else: numbers

      {:ok, %__MODULE__{brand: choose_brand(numbers), number: numbers}}
    end
  end

  @doc """
  iex> PaymentCardNumber.mask(1234567890123456)
  "XXXX-XXXX-XXXX-3456"
  iex> PaymentCardNumber.mask(%{number: "1234567890123456"})
  "XXXX-XXXX-XXXX-3456"
  iex> PaymentCardNumber.mask("1234567890123456")
  "XXXX-XXXX-XXXX-3456"
  """
  # POSSIBLE BUG: no validation checks are used on masking
  @spec mask(String.t | integer | t) :: String.t
  def mask(%{number: number}) do
    mask(number)
  end

  def mask(numbers) do
    "XXXX-XXXX-XXXX-#{last_digits(numbers)}"
  end

  defp validate_length(number) when is_binary(number) do
    if String.length(number) >= 12,
      do: :ok,
    else: {:error, :invalid_length}
  end

  defp validate_length(number) when is_integer(number) do
    if number >= 100_000_000_000,
      do: :ok,
    else: {:error, :invalid_length}
  end

  defp validate_luhn(number) do
    if LuhnAlgorithm.checksum(number),
      do: :ok,
    else: {:error, :failed_checksum}
  end

  defp last_digits(numbers, length \\ 4)
  defp last_digits(numbers, length) when is_binary(numbers) do
    String.slice(numbers, -length, length)
  end
  defp last_digits(numbers, length) when is_integer(numbers) do
    numbers
    |> Integer.digits()
    |> Enum.reverse()
    |> Enum.take(length)
    |> Enum.reverse
    |> Integer.undigits
  end

  defp choose_brand(numbers) do
    case Enum.filter(@companies, fn {_, match} ->
           String.match?(numbers, match)
         end)
    do
      [{brand, _} | []] -> brand
      [] -> :unknown_brand
      any -> raise ArgumentError, "#{inspect any} has more than one match"
    end
  end
end
