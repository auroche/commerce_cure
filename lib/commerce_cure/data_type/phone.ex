defmodule CommerceCure.Phone do
  # rfc 3966?
  @type phone_number :: String.t
  @type t :: %__MODULE__{number: phone_number}

  @enforce_keys [:number]
  defstruct     [:number]

  def new(number) when is_binary(number) do
    if String.match?(number, ~r/\d+/) do
      {:ok, %__MODULE__{number: number}}
    else
      {:error, :invalid_number}
    end
  end

  def new(number) when is_integer(number) do
    %__MODULE__{number: Integer.to_string(number)}
  end

  def parse_pass(number) do
    case new(number) do
      {:ok, number} ->
        number
      any ->
        any
    end
  end

  def parse() do
    # stub
  end

  # TODO: pick countries
  defp choose_countries(number) do
    # stub
  end

  defp choose_format(country) do
    # stub
  end

end
